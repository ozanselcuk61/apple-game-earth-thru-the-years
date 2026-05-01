const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const { GoogleGenerativeAI } = require("@google/generative-ai");
const Stripe = require("stripe");

admin.initializeApp();
const db = admin.firestore();

const GEMINI_KEY = defineSecret("GEMINI_KEY");
const STRIPE_SECRET = defineSecret("STRIPE_SECRET");

// ---- AI REPORT GENERATION ----
exports.generateReport = onRequest(
  { cors: true, secrets: [GEMINI_KEY] },
  async (req, res) => {
    if (req.method !== "POST") return res.status(405).json({ error: "Method not allowed" });

    try {
      const { userId, projectData, sections, language } = req.body;
      if (!userId || !projectData) return res.status(400).json({ error: "Missing fields" });

      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) return res.status(403).json({ error: "User not found" });

      const genAI = new GoogleGenerativeAI(GEMINI_KEY.value());
      const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });

      const selectedSections = sections || [
        "Executive Summary", "Work Package Progress", "Budget Execution",
        "Partner Contributions", "Dissemination & Impact", "Challenges & Mitigations"
      ];

      const prompt = buildReportPrompt(projectData, selectedSections, language || "English");
      const result = await model.generateContent(prompt);
      const reportText = result.response.text();

      const reportRef = await db.collection("users").doc(userId).collection("reports").add({
        projectId: projectData.id,
        projectName: projectData.name,
        content: reportText,
        sections: selectedSections,
        language: language || "English",
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });

      return res.status(200).json({ success: true, reportId: reportRef.id, content: reportText });
    } catch (error) {
      console.error("Report error:", error);
      return res.status(500).json({ error: "Failed to generate report", details: error.message });
    }
  }
);

function buildReportPrompt(project, sections, language) {
  const partners = project.partners || [];
  const wps = project.workPackages || [];
  const tasks = project.tasks || [];
  const diss = project.dissemination || {};

  return `You are an expert EU project report writer. Generate a comprehensive final report for an EU-funded Erasmus+ project in ${language}.

PROJECT INFORMATION:
- Name: ${project.name}
- Programme: ${project.programme || "Erasmus+ KA220"}
- Project Number: ${project.projectNumber || "N/A"}
- Duration: ${project.startDate || "N/A"} to ${project.endDate || "N/A"} (${project.duration || 24} months)
- Total Grant (Lump Sum): €${project.totalBudget || 0}
- Coordinator: ${project.coordinator || "N/A"} (${project.coordinatorCountry || "N/A"})
- Description: ${project.description || "N/A"}

PARTNERS (${partners.length}):
${partners.map(p => `- ${p.name} (${p.country || "N/A"}) — ${p.role || "partner"}, Budget: €${p.budget || 0}`).join("\n")}

WORK PACKAGES (${wps.length}):
${wps.map(wp => `- ${wp.number || wp.id}: ${wp.title} — Lead: ${wp.lead || "N/A"}, Progress: ${wp.progress || 0}%, Budget: €${wp.budget || 0}\n  ${wp.description || ""}`).join("\n")}

TASKS (${tasks.length}):
${tasks.map(t => `- ${t.title} (${t.wp || "N/A"}) — Status: ${t.status || "pending"}`).join("\n")}

DISSEMINATION:
- Events: ${diss.summary?.events || 0}, Publications: ${diss.summary?.publications || 0}
- Social Reach: ${diss.summary?.socialReach || 0}, Website Visits: ${diss.summary?.website_visits || 0}

Generate these sections:
${sections.map((s, i) => `${i + 1}. ${s}`).join("\n")}

REQUIREMENTS:
- Follow EU final report structure
- Professional, data-driven language
- Each section 150-300 words
- Use markdown headings (## for sections)
- Reference specific data from above`;
}

// ---- STRIPE CHECKOUT ----
exports.createCheckoutSession = onRequest(
  { cors: true, secrets: [STRIPE_SECRET] },
  async (req, res) => {
    if (req.method !== "POST") return res.status(405).json({ error: "Method not allowed" });

    try {
      const stripe = new Stripe(STRIPE_SECRET.value());
      const { priceId, userId, email, successUrl, cancelUrl } = req.body;

      const session = await stripe.checkout.sessions.create({
        payment_method_types: ["card"],
        line_items: [{ price: priceId || "price_1TS4jk5lr58PCaKEKvt9wVDE", quantity: 1 }],
        mode: "subscription",
        success_url: successUrl + "?payment=success",
        cancel_url: cancelUrl + "?payment=cancel",
        customer_email: email,
        metadata: { userId }
      });

      return res.status(200).json({ sessionId: session.id, url: session.url });
    } catch (error) {
      console.error("Checkout error:", error);
      return res.status(500).json({ error: error.message });
    }
  }
);

// ---- STRIPE PORTAL ----
exports.createPortalSession = onRequest(
  { cors: true, secrets: [STRIPE_SECRET] },
  async (req, res) => {
    if (req.method !== "POST") return res.status(405).json({ error: "Method not allowed" });

    try {
      const stripe = new Stripe(STRIPE_SECRET.value());
      const { userId, returnUrl } = req.body;

      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) return res.status(404).json({ error: "User not found" });

      const customers = await stripe.customers.list({ email: userDoc.data().email, limit: 1 });
      if (customers.data.length === 0) return res.status(404).json({ error: "No customer found" });

      const session = await stripe.billingPortal.sessions.create({
        customer: customers.data[0].id,
        return_url: returnUrl
      });

      return res.status(200).json({ url: session.url });
    } catch (error) {
      console.error("Portal error:", error);
      return res.status(500).json({ error: error.message });
    }
  }
);

// ---- STRIPE WEBHOOK ----
exports.stripeWebhook = onRequest(async (req, res) => {
  try {
    const event = req.body;

    if (event.type === "checkout.session.completed") {
      const userId = event.data.object.metadata?.userId;
      if (userId) {
        await db.collection("users").doc(userId).update({
          plan: "premium",
          stripeCustomerId: event.data.object.customer,
          premiumSince: admin.firestore.FieldValue.serverTimestamp()
        });
      }
    }

    if (event.type === "customer.subscription.deleted") {
      const snap = await db.collection("users")
        .where("stripeCustomerId", "==", event.data.object.customer).get();
      snap.forEach(async (doc) => { await doc.ref.update({ plan: "expired" }); });
    }

    res.status(200).json({ received: true });
  } catch (error) {
    console.error("Webhook error:", error);
    res.status(400).json({ error: error.message });
  }
});

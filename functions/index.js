const functions = require("firebase-functions");
const admin = require("firebase-admin");
const cors = require("cors")({ origin: true });
const Anthropic = require("@anthropic-ai/sdk");
const Stripe = require("stripe");

admin.initializeApp();
const db = admin.firestore();

// ---- CONFIG ----
const ANTHROPIC_API_KEY = functions.config().anthropic?.key || "";
const STRIPE_SECRET_KEY = functions.config().stripe?.secret || "";
const STRIPE_PRICE_ID = functions.config().stripe?.price_id || "price_1TS4jk5lr58PCaKEKvt9wVDE";

// ---- AI REPORT GENERATION ----
exports.generateReport = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    if (req.method !== "POST") {
      return res.status(405).json({ error: "Method not allowed" });
    }

    try {
      const { userId, projectData, sections, language } = req.body;

      if (!userId || !projectData) {
        return res.status(400).json({ error: "Missing required fields" });
      }

      // Verify user exists
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) {
        return res.status(403).json({ error: "User not found" });
      }

      // Check plan (only premium or trial users can generate)
      const userData = userDoc.data();
      if (userData.plan !== "premium" && userData.plan !== "trial") {
        return res.status(403).json({ error: "Upgrade to Premium to generate reports" });
      }

      const client = new Anthropic({ apiKey: ANTHROPIC_API_KEY });

      const selectedSections = sections || [
        "Executive Summary",
        "Work Package Progress",
        "Budget Execution",
        "Partner Contributions",
        "Dissemination & Impact",
        "Challenges & Mitigations",
      ];

      const prompt = buildReportPrompt(projectData, selectedSections, language || "English");

      const message = await client.messages.create({
        model: "claude-sonnet-4-20250514",
        max_tokens: 4000,
        messages: [
          {
            role: "user",
            content: prompt,
          },
        ],
      });

      const reportText = message.content[0].text;

      // Save report to Firestore
      const reportRef = await db
        .collection("users")
        .doc(userId)
        .collection("reports")
        .add({
          projectId: projectData.id,
          projectName: projectData.name,
          content: reportText,
          sections: selectedSections,
          language: language || "English",
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      return res.status(200).json({
        success: true,
        reportId: reportRef.id,
        content: reportText,
      });
    } catch (error) {
      console.error("Report generation error:", error);
      return res.status(500).json({
        error: "Failed to generate report",
        details: error.message,
      });
    }
  });
});

function buildReportPrompt(project, sections, language) {
  const partners = project.partners || [];
  const wps = project.workPackages || [];
  const dissemination = project.dissemination || {};
  const tasks = project.tasks || [];

  let prompt = `You are an expert EU project report writer. Generate a comprehensive final report for an EU-funded Erasmus+ project in ${language}.

PROJECT INFORMATION:
- Name: ${project.name}
- Programme: ${project.programme || "Erasmus+ KA220"}
- Project Number: ${project.projectNumber || "N/A"}
- Duration: ${project.startDate || "N/A"} to ${project.endDate || "N/A"} (${project.duration || 24} months)
- Total Grant (Lump Sum): €${project.totalBudget || 0}
- Coordinator: ${project.coordinator || "N/A"} (${project.coordinatorCountry || "N/A"})
- Description: ${project.description || "N/A"}

PARTNER ORGANIZATIONS (${partners.length}):
${partners.map((p) => `- ${p.name} (${p.country || "N/A"}) — Role: ${p.role || "partner"}, Budget: €${p.budget || 0}, Contact: ${p.contact || "N/A"}`).join("\n")}

WORK PACKAGES (${wps.length}):
${wps.map((wp) => `- ${wp.number || wp.id}: ${wp.title} — Lead: ${wp.lead || "N/A"}, Progress: ${wp.progress || 0}%, Status: ${wp.status || "pending"}, Budget: €${wp.budget || 0}\n  Description: ${wp.description || "N/A"}`).join("\n")}

TASKS (${tasks.length}):
${tasks.map((t) => `- ${t.title} (${t.wp || "N/A"}) — Status: ${t.status || "pending"}, Assignee: ${t.assignee || "N/A"}, Due: ${t.due || "N/A"}`).join("\n")}

DISSEMINATION:
- Events: ${dissemination.summary?.events || 0}
- Publications: ${dissemination.summary?.publications || 0}
- Social Media Reach: ${dissemination.summary?.socialReach || 0}
- Website Visits: ${dissemination.summary?.website_visits || 0}
${(dissemination.activities || []).map((a) => `- ${a.title} (${a.type}, ${a.date}) — Reach: ${a.reach || 0}`).join("\n")}

Please generate the following sections for the final report:
${sections.map((s, i) => `${i + 1}. ${s}`).join("\n")}

REQUIREMENTS:
- Follow EU final report template structure
- Be professional, detailed, and data-driven
- Reference specific deliverables, dates, and metrics from the data above
- Use formal academic/institutional language
- Each section should be 150-300 words
- Include concrete achievements and measurable outcomes
- For the budget section, explain the lump-sum model compliance
- Format with clear headings using markdown (## for sections)`;

  return prompt;
}

// ---- STRIPE CHECKOUT ----
exports.createCheckoutSession = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    if (req.method !== "POST") {
      return res.status(405).json({ error: "Method not allowed" });
    }

    try {
      const stripe = new Stripe(STRIPE_SECRET_KEY);
      const { priceId, userId, email, successUrl, cancelUrl } = req.body;

      const session = await stripe.checkout.sessions.create({
        payment_method_types: ["card"],
        line_items: [{ price: priceId || STRIPE_PRICE_ID, quantity: 1 }],
        mode: "subscription",
        success_url: successUrl + "?payment=success",
        cancel_url: cancelUrl + "?payment=cancel",
        customer_email: email,
        metadata: { userId: userId },
      });

      return res.status(200).json({ sessionId: session.id, url: session.url });
    } catch (error) {
      console.error("Checkout error:", error);
      return res.status(500).json({ error: error.message });
    }
  });
});

// ---- STRIPE CUSTOMER PORTAL ----
exports.createPortalSession = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    if (req.method !== "POST") {
      return res.status(405).json({ error: "Method not allowed" });
    }

    try {
      const stripe = new Stripe(STRIPE_SECRET_KEY);
      const { userId, returnUrl } = req.body;

      // Find customer by email
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) {
        return res.status(404).json({ error: "User not found" });
      }

      const email = userDoc.data().email;
      const customers = await stripe.customers.list({ email: email, limit: 1 });

      if (customers.data.length === 0) {
        return res.status(404).json({ error: "No Stripe customer found" });
      }

      const session = await stripe.billingPortal.sessions.create({
        customer: customers.data[0].id,
        return_url: returnUrl,
      });

      return res.status(200).json({ url: session.url });
    } catch (error) {
      console.error("Portal error:", error);
      return res.status(500).json({ error: error.message });
    }
  });
});

// ---- STRIPE WEBHOOK ----
exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  try {
    const event = req.body;

    if (event.type === "checkout.session.completed") {
      const session = event.data.object;
      const userId = session.metadata?.userId;

      if (userId) {
        await db.collection("users").doc(userId).update({
          plan: "premium",
          stripeCustomerId: session.customer,
          stripeSubscriptionId: session.subscription,
          premiumSince: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    }

    if (event.type === "customer.subscription.deleted") {
      const subscription = event.data.object;
      // Find user by stripe customer ID
      const usersSnap = await db
        .collection("users")
        .where("stripeCustomerId", "==", subscription.customer)
        .get();

      usersSnap.forEach(async (doc) => {
        await doc.ref.update({ plan: "expired" });
      });
    }

    res.status(200).json({ received: true });
  } catch (error) {
    console.error("Webhook error:", error);
    res.status(400).json({ error: error.message });
  }
});

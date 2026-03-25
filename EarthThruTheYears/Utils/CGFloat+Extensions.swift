import CoreGraphics

extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }

    static func lerp(from a: CGFloat, to b: CGFloat, t: CGFloat) -> CGFloat {
        return a + (b - a) * t.clamped(to: 0...1)
    }

    static func randomInRange(_ min: CGFloat, _ max: CGFloat) -> CGFloat {
        return CGFloat.random(in: min...max)
    }
}

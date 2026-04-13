import CoreGraphics

struct InputState {
    var horizontalDirection: CGFloat = 0 // -1 (left) to 1 (right)
    var jumpPressed: Bool = false
    var jumpJustPressed: Bool = false
    var actionPressed: Bool = false

    mutating func reset() {
        horizontalDirection = 0
        jumpPressed = false
        jumpJustPressed = false
        actionPressed = false
    }
}

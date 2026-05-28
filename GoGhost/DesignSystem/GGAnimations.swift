import SwiftUI

struct GGAnimations {
    static let standard     = Animation.easeInOut(duration: 0.25)
    static let slow         = Animation.easeInOut(duration: 0.6)
    static let ringFill     = Animation.easeOut(duration: 1.2)
    static let scoreReveal  = Animation.spring(response: 0.5, dampingFraction: 0.75)
}

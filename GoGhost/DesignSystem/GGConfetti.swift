import SwiftUI

// On-brand confetti — small rotated rectangles in green/white falling from the top.
//
// Design decisions:
// • Uses `let` constants (not @State) so the Canvas closure always has fresh values.
// • Callers control identity with `.id(...)`:
//     - Stable id  → confetti fires once and plays through (ScoreRevealView)
//     - New UUID   → forces view recreation, restarting the burst (RunCompleteView page changes)

struct GGConfettiView: View {
    // @State so SwiftUI initializes these ONCE per view identity and preserves them
    // across parent re-renders. A plain `let` would re-randomize particles and reset
    // startDate every render, making the animation visibly restart ("reloading").
    @State private var particles: [Particle]
    @State private var startDate: Date

    init(count: Int = 110, fixedStart: Date? = nil) {
        _startDate = State(initialValue: fixedStart ?? Date())
        let palette: [Color] = [
            Color(hex: "22C55E"), Color(hex: "22C55E"), Color(hex: "22C55E"), Color(hex: "22C55E"),
            .white, .white, .white,
            Color(hex: "4ADE80"), Color(hex: "4ADE80"),
            Color(hex: "86EFAC")
        ]
        let generated = (0..<count).map { _ in
            Particle(
                x:          CGFloat.random(in: -0.05...1.05),
                y:          CGFloat.random(in: -0.08...0.0),
                vx:         CGFloat.random(in: -0.07...0.07),
                vy:         CGFloat.random(in: 0.10...0.28),
                w:          CGFloat.random(in: 4...9),
                h:          CGFloat.random(in: 8...15),
                startAngle: Double.random(in: 0 ... .pi * 2),
                spin:       Double.random(in: -5...5),
                color:      palette.randomElement()!,
                delay:      Double.random(in: 0...0.5)
            )
        }
        _particles = State(initialValue: generated)
    }

    var body: some View {
        let p = particles
        let s = startDate

        TimelineView(.animation) { timeline in
            Canvas { ctx, size in
                let elapsed = timeline.date.timeIntervalSince(s)
                guard elapsed > 0 else { return }

                for particle in p {
                    let t = elapsed - particle.delay
                    guard t > 0 else { continue }

                    let x = particle.x * size.width  + particle.vx * t * size.width
                    let y = particle.y * size.height + particle.vy * t * size.height + 180 * t * t

                    guard y < size.height + 20 else { continue }

                    let fadeIn  = min(t / 0.2, 1.0)
                    let progress = y / max(size.height, 1)
                    let fadeOut = progress > 0.70 ? max(0.0, 1.0 - (progress - 0.70) / 0.30) : 1.0
                    let alpha   = fadeIn * fadeOut
                    guard alpha > 0.01 else { continue }

                    let angle = particle.startAngle + particle.spin * t
                    let cosA = CGFloat(cos(angle)); let sinA = CGFloat(sin(angle))
                    let hw = particle.w / 2;        let hh  = particle.h / 2

                    var path = Path()
                    path.move(to:    CGPoint(x: x + (-hw*cosA - -hh*sinA), y: y + (-hw*sinA + -hh*cosA)))
                    path.addLine(to: CGPoint(x: x + ( hw*cosA - -hh*sinA), y: y + ( hw*sinA + -hh*cosA)))
                    path.addLine(to: CGPoint(x: x + ( hw*cosA -  hh*sinA), y: y + ( hw*sinA +  hh*cosA)))
                    path.addLine(to: CGPoint(x: x + (-hw*cosA -  hh*sinA), y: y + (-hw*sinA +  hh*cosA)))
                    path.closeSubpath()

                    var c = ctx
                    c.opacity = alpha
                    c.fill(path, with: .color(particle.color))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private struct Particle {
    let x, y, vx, vy, w, h: CGFloat
    let startAngle, spin: Double
    let color: Color
    let delay: Double
}

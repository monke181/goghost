import SwiftUI

// On-brand confetti — small rotated rectangles in green/white falling from the top.
// @State holds startDate and particles so parent re-renders don't restart the animation.

struct GGConfettiView: View {
    var count: Int = 110

    @State private var particles: [Particle] = []
    @State private var startDate: Date = .distantFuture

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { ctx, size in
                let elapsed = timeline.date.timeIntervalSince(startDate)
                guard elapsed >= 0, !particles.isEmpty else { return }

                for p in particles {
                    let t = elapsed - p.delay
                    guard t > 0 else { continue }

                    let x = p.x * size.width + p.vx * t * size.width
                    let y = p.y * size.height + p.vy * t * size.height + 180 * t * t

                    guard y < size.height + 20 else { continue }

                    let fadeIn  = min(t / 0.25, 1.0)
                    let progress = y / max(size.height, 1)
                    let fadeOut = progress > 0.72 ? max(0, 1 - (progress - 0.72) / 0.28) : 1.0
                    let alpha   = fadeIn * fadeOut
                    guard alpha > 0 else { continue }

                    let angle = p.startAngle + p.spin * t
                    let cosA = CGFloat(cos(angle))
                    let sinA = CGFloat(sin(angle))
                    let hw = p.w / 2; let hh = p.h / 2

                    var path = Path()
                    path.move(to:    CGPoint(x: x + (-hw*cosA - -hh*sinA), y: y + (-hw*sinA + -hh*cosA)))
                    path.addLine(to: CGPoint(x: x + ( hw*cosA - -hh*sinA), y: y + ( hw*sinA + -hh*cosA)))
                    path.addLine(to: CGPoint(x: x + ( hw*cosA -  hh*sinA), y: y + ( hw*sinA +  hh*cosA)))
                    path.addLine(to: CGPoint(x: x + (-hw*cosA -  hh*sinA), y: y + (-hw*sinA +  hh*cosA)))
                    path.closeSubpath()

                    var c = ctx
                    c.opacity = alpha
                    c.fill(path, with: .color(p.color))
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear {
            // Only initialize once — @State persists these across parent re-renders
            guard particles.isEmpty else { return }
            particles = makeParticles()
            startDate = .now
        }
    }

    private func makeParticles() -> [Particle] {
        let palette: [Color] = [
            Color(hex: "22C55E"), Color(hex: "22C55E"), Color(hex: "22C55E"), Color(hex: "22C55E"),
            .white, .white, .white,
            Color(hex: "4ADE80"), Color(hex: "4ADE80"),
            Color(hex: "86EFAC")
        ]
        return (0..<count).map { _ in
            Particle(
                x:          CGFloat.random(in: -0.05...1.05),
                y:          CGFloat.random(in: -0.08...0.02),
                vx:         CGFloat.random(in: -0.07...0.07),
                vy:         CGFloat.random(in: 0.12...0.30),
                w:          CGFloat.random(in: 4...8),
                h:          CGFloat.random(in: 8...14),
                startAngle: Double.random(in: 0 ... .pi * 2),
                spin:       Double.random(in: -5...5),
                color:      palette.randomElement()!,
                delay:      Double.random(in: 0...0.55)
            )
        }
    }
}

private struct Particle {
    let x, y, vx, vy, w, h: CGFloat
    let startAngle, spin: Double
    let color: Color
    let delay: Double
}

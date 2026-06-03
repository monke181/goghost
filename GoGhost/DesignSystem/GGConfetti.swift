import SwiftUI

// On-brand confetti — small rotated rectangles in green/white falling from the top.
// Designed for celebration moments only: score ≥ 80, new bests, milestones, run complete.

struct GGConfettiView: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { ctx, size in
                let now = timeline.date.timeIntervalSince(startDate)
                for p in particles {
                    let t = now - p.delay
                    guard t > 0 else { continue }

                    let x = p.x * size.width + p.vx * t * size.width
                    let y = p.y * size.height + p.vy * t * size.height + 180 * t * t

                    guard y < size.height + 20 else { continue }

                    let progress = y / size.height
                    let fadeIn  = min(t / 0.25, 1.0)
                    let fadeOut = progress > 0.72 ? max(0.0, 1.0 - (progress - 0.72) / 0.28) : 1.0
                    let alpha   = fadeIn * fadeOut
                    guard alpha > 0 else { continue }

                    let angle = p.startAngle + p.spin * t
                    let cosA = CGFloat(cos(angle))
                    let sinA = CGFloat(sin(angle))
                    let hw = p.w / 2
                    let hh = p.h / 2

                    // Rotate corners of rectangle
                    var path = Path()
                    path.move(to:    CGPoint(x: x + (-hw * cosA - -hh * sinA), y: y + (-hw * sinA + -hh * cosA)))
                    path.addLine(to: CGPoint(x: x + ( hw * cosA - -hh * sinA), y: y + ( hw * sinA + -hh * cosA)))
                    path.addLine(to: CGPoint(x: x + ( hw * cosA -  hh * sinA), y: y + ( hw * sinA +  hh * cosA)))
                    path.addLine(to: CGPoint(x: x + (-hw * cosA -  hh * sinA), y: y + (-hw * sinA +  hh * cosA)))
                    path.closeSubpath()

                    var c = ctx
                    c.opacity = alpha
                    c.fill(path, with: .color(p.color))
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    // Created once on init so the view is stateless and restartable
    private let particles: [Particle]
    private let startDate: Date

    init(count: Int = 110) {
        let palette: [Color] = [
            Color(hex: "22C55E"),   // brand green  — 40%
            Color(hex: "22C55E"),
            Color(hex: "22C55E"),
            Color(hex: "22C55E"),
            .white,                 // white         — 35%
            .white,
            .white,
            Color(hex: "4ADE80"),   // lighter green — 15%
            Color(hex: "4ADE80"),
            Color(hex: "86EFAC"),   // pale green    — 10%
        ]
        startDate = .now
        particles = (0..<count).map { _ in
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

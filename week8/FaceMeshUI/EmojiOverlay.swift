//
//  EmojiOverlay.swift
//  FaceMeshUI
//
//  Full-screen emoji that float up from the bottom, driven by facial expressions.
//  Uses the same checks as the status text in FaceTracker:
//  - smiling → 😊😄🥰😆 ... (bigger smile = more emoji)
//  - winking → 😉        (more closed eye = more emoji)
//

import SwiftUI

/// One emoji on screen.
struct EmojiParticle {
    var emoji: String
    var x: CGFloat
    var y: CGFloat
    var vx: CGFloat          // horizontal speed (points / second)
    var vy: CGFloat          // vertical speed (points / second, negative = up)
    var size: CGFloat
    var spin: Double         // rotation speed (radians / second)
    var angle: Double = 0
    var age: Double = 0
    var life: Double         // seconds before it disappears
}

/// Spawns and moves particles. A plain class (not @Observable) because
/// TimelineView already redraws every frame.
final class EmojiSystem {
    var particles: [EmojiParticle] = []

    private var lastDate: Date?
    private var smileBudget: Double = 0    // fractional emoji waiting to be spawned
    private var winkBudget: Double = 0

    private let smileEmojis = ["😊", "😄", "😁", "🥰", "😆", "☺️"]
    private let winkEmojis = ["😉"]
    private let emojiPerSecond = 40.0      // spawn rate when the value is 1.0
    private let maxParticles = 300

    func step(date: Date, size: CGSize, tracker: FaceTracker) {
        // Time since last frame (capped so a pause doesn't make things jump)
        let dt = min(date.timeIntervalSince(lastDate ?? date), 1.0 / 20.0)
        lastDate = date
        guard size.width > 0 else { return }

        // Smile: spawn rate grows with how big the smile is
        if tracker.isSmiling {
            spawn(value: tracker.smile, dt: dt, budget: &smileBudget, emojis: smileEmojis, size: size)
        } else {
            smileBudget = 0
        }

        // Wink: spawn rate grows with how closed the winking eye is
        if tracker.isWinking {
            let closedEye = max(tracker.blinkLeft, tracker.blinkRight)
            spawn(value: closedEye, dt: dt, budget: &winkBudget, emojis: winkEmojis, size: size)
        } else {
            winkBudget = 0
        }

        // Move everything
        for i in particles.indices {
            particles[i].x += particles[i].vx * CGFloat(dt)
            particles[i].y += particles[i].vy * CGFloat(dt)
            particles[i].angle += particles[i].spin * dt
            particles[i].age += dt
        }

        // Remove old or off-screen emoji
        particles.removeAll { p in p.age > p.life || p.y < -100 }
        if particles.count > maxParticles {
            particles.removeFirst(particles.count - maxParticles)
        }
    }

    /// Adds emoji at a rate of value * emojiPerSecond
    private func spawn(value: Float, dt: Double, budget: inout Double,
                       emojis: [String], size: CGSize) {
        budget += Double(value) * emojiPerSecond * dt
        while budget >= 1 {
            budget -= 1
            spawnRising(emoji: emojis.randomElement()!, size: size)
        }
    }

    /// Rise from below the screen, drifting slightly
    private func spawnRising(emoji: String, size: CGSize) {
        particles.append(EmojiParticle(
            emoji: emoji,
            x: .random(in: 0...size.width),
            y: size.height + 40,
            vx: .random(in: -30...30),
            vy: .random(in: -350 ... -150),
            size: .random(in: 30...70),
            spin: .random(in: -1...1),
            life: 5
        ))
    }
}

/// Transparent full-screen layer that draws the particles every frame.
struct EmojiOverlay: View {
    let tracker: FaceTracker
    @State private var system = EmojiSystem()

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                system.step(date: timeline.date, size: size, tracker: tracker)

                for p in system.particles {
                    var ctx = context
                    // fade out during the last 0.6 seconds of life
                    let remaining = p.life - p.age
                    ctx.opacity = remaining < 0.6 ? max(0, remaining / 0.6) : 1
                    ctx.translateBy(x: p.x, y: p.y)
                    ctx.rotate(by: .radians(p.angle))
                    ctx.draw(Text(p.emoji).font(.system(size: p.size)), at: .zero)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

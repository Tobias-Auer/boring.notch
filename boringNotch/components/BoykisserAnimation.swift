//
//  BoykisserAnimation.swift
//  boringNotch
//
//  Subtle, idle animation for the boykisser asset shown
//  in the closed notch while the player is inactive.
//

import SwiftUI

struct BoykisserAnimation: View {
    @State private var height: CGFloat = 20
    @State private var width: CGFloat = 30

    // Animation state
    @State private var breathe: Bool = false
    @State private var sway: Bool = false
    @State private var bob: Bool = false
    @State private var isBlinking: Bool = false
    @State private var blinkTask: Task<Void, Never>? = nil

    init(height: CGFloat = 20, width: CGFloat = 30) {
        _height = State(initialValue: height)
        _width = State(initialValue: width)
    }

    var body: some View {
        Image(isBlinking ? "boykisser-blink" : "boykisser")
            .resizable()
            .renderingMode(.original)
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: height)
            // Gentle "breathing" scale
            .scaleEffect(breathe ? 1.04 : 0.98, anchor: .bottom)
            // Slow side-to-side head sway
            .rotationEffect(.degrees(sway ? 2.5 : -2.5), anchor: .bottom)
            // Tiny vertical bob, out of phase with the sway
            .offset(y: bob ? -0.8 : 0.8)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.4).repeatForever(autoreverses: true)
                ) {
                    breathe = true
                }
                withAnimation(
                    .easeInOut(duration: 3.6).repeatForever(autoreverses: true)
                ) {
                    sway = true
                }
                withAnimation(
                    .easeInOut(duration: 1.8).repeatForever(autoreverses: true)
                ) {
                    bob = true
                }
                startBlinking()
            }
            .onDisappear {
                blinkTask?.cancel()
                blinkTask = nil
            }
    }

    private func startBlinking() {
        blinkTask?.cancel()
        blinkTask = Task { @MainActor in
            // Small initial delay so the blink doesn't fire on the first frame.
            try? await Task.sleep(nanoseconds: UInt64.random(in: 1_500_000_000...3_500_000_000))
            while !Task.isCancelled {
                // Single blink: closed eyes for ~140ms
                isBlinking = true
                try? await Task.sleep(nanoseconds: 140_000_000)
                isBlinking = false

                // ~20% chance of a quick double-blink
                if Bool.random() && Int.random(in: 0...4) == 0 {
                    try? await Task.sleep(nanoseconds: 120_000_000)
                    isBlinking = true
                    try? await Task.sleep(nanoseconds: 130_000_000)
                    isBlinking = false
                }

                // Random gap between blinks: 3–6 seconds
                let gap = UInt64.random(in: 3_000_000_000...6_000_000_000)
                try? await Task.sleep(nanoseconds: gap)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black
        BoykisserAnimation(height: 60, width: 60)
    }
    .frame(width: 120, height: 120)
}

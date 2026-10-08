// xcode: set sdk=iOS

import SwiftUI
import Combine

// time to grow a tree
let secondsPerTree = 5

// choose how many trees
struct ContentView: View {
    @State private var treeCount = 3
    @State private var isPlanting = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("🌳 Plant a Forest")
                    .font(Font.custom("American Typewriter", size: 38))
                    .bold()

                Stepper("\(treeCount) trees", value: $treeCount, in: 1...20)
                    .font(Font.custom("American Typewriter", size: 24))

                Text("Each tree takes \(secondsPerTree)s")
                    .font(Font.custom("American Typewriter", size: 16))
                    .foregroundStyle(.gray)

                Button("Start Planting") {
                    isPlanting = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .font(Font.custom("American Typewriter", size: 16))
            }
            .padding()
            .tint(.green)
            .navigationDestination(isPresented: $isPlanting) {
                PlantingView(treeCount: treeCount)
            }
        }
    }
}

// grow the trees
struct PlantingView: View {
    let treeCount: Int

    @Environment(\.dismiss) private var dismiss
    @State private var secondsLeft = 0

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // how many trees have finished growing
    var grownTrees: Int {
        let elapsed = treeCount * secondsPerTree - secondsLeft
        return elapsed / secondsPerTree
    }

    // grown = 🌳，growing = 🌱，not started yet = 🟫
    func emoji(for index: Int) -> String {
        if index < grownTrees {
            return "🌳"
        } else if index == grownTrees {
            return "🌱"
        } else {
            return "🟫"
        }
    }

    var forest: String {
        (0..<treeCount)
            .map { emoji(for: $0) }
            .joined(separator: " ")
    }

    var body: some View {
        VStack(spacing: 30) {
            Text(secondsLeft == 0 ? "🎉 Forest Complete!" : "\(secondsLeft)s")
                .font(Font.custom("AmericanTypewriter-Bold", size: 48))
                

            Text(forest)
                .font(Font.custom("AmericanTypewriter", size: 40))
                .multilineTextAlignment(.center)

            Button(secondsLeft == 0 ? "Done" : "Give Up") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .font(Font.custom("AmericanTypewriter", size: 16))
        }
        .padding()
        .tint(.green)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            secondsLeft = treeCount * secondsPerTree
        }
        .onReceive(timer) { _ in
            if secondsLeft > 0 {
                secondsLeft -= 1
            }
        }
    }
}

#Preview {
    ContentView()
}

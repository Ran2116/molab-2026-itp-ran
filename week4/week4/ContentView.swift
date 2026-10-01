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
                    .font(.largeTitle)
                    .bold()

                Stepper("\(treeCount) trees", value: $treeCount, in: 1...20)
                    .font(.title2)

                Text("Each tree takes \(secondsPerTree)s")
                    .foregroundStyle(.secondary)

                Button("Start Planting") {
                    isPlanting = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
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
                .font(.system(size: 48, weight: .bold, design: .monospaced))

            Text(forest)
                .font(.system(size: 40))
                .multilineTextAlignment(.center)

            Button(secondsLeft == 0 ? "Done" : "Give Up") {
                dismiss()
            }
            .buttonStyle(.bordered)
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

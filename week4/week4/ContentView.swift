import SwiftUI
import AVFoundation
import Combine

// time requires to grow a tree
let secondsPerTree: Double = 5

// format the time,make it more readable
func formatTime(_ seconds: Double) -> String {
    let s = max(0, Int(seconds.rounded(.up)))
    let h = s / 3600
    let m = (s % 3600) / 60
    let sec = s % 60
    if h > 0 {
        return String(format: "%d:%02d:%02d", h, m, sec)
    } else {
        return String(format: "%02d:%02d", m, sec)
    }
}

// set how many trees we gonna grow

struct ContentView: View {
    @State private var treeCount = 3
    @State private var isPlanting = false

    let minTrees = 1
    let maxTrees = 20

    var totalSeconds: Double {
        Double(treeCount) * secondsPerTree
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {

                Text("🌳 Plant a Forest")
                    .font(.largeTitle)
                    .bold()

                Text(formatTime(totalSeconds))
                    .font(.system(size: 60, weight: .bold, design: .monospaced))

                Text("🌳")
                    .font(.system(size: 90))

                HStack(spacing: 30) {
                    Button {
                        if treeCount > minTrees { treeCount -= 1 }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 40))
                    }
                    .disabled(treeCount <= minTrees)

                    Text("\(treeCount) \(treeCount == 1 ? "tree" : "trees")")
                        .font(.title2)
                        .frame(minWidth: 100)

                    Button {
                        if treeCount < maxTrees { treeCount += 1 }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 40))
                    }
                    .disabled(treeCount >= maxTrees)
                }
                .tint(.green)

                Text("Each tree takes \(formatTime(secondsPerTree))")
                    .foregroundStyle(.secondary)

                Button("Start Planting") {
                    isPlanting = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .controlSize(.large)
            }
            .padding()
            .navigationDestination(isPresented: $isPlanting) {
                PlantingView(treeCount: treeCount)
            }
        }
    }
}

// growing the tree

struct PlantingView: View {
    let treeCount: Int
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var startDate = Date()
    @State private var now = Date()
    @State private var player: AVAudioPlayer?
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // five tree in a row
    let columns = Array(repeating: GridItem(.flexible()), count: 5)
    
    var totalSeconds: Double {
        Double(treeCount) * secondsPerTree
    }
    
    var elapsed: Double {
        min(now.timeIntervalSince(startDate), totalSeconds)
    }
    
    var remaining: Double {
        totalSeconds - elapsed
    }
    
    var grownTrees: Int {
        min(Int(elapsed / secondsPerTree), treeCount)
    }
    
    var isFinished: Bool {
        grownTrees >= treeCount
    }
    
    var body: some View {
        VStack(spacing: 24) {
            
            Text(isFinished ? "🎉 Forest Complete!" : "Planting...")
                .font(.largeTitle)
                .bold()
            
            Text(formatTime(remaining))
                .font(.system(size: 56, weight: .bold, design: .monospaced))
            
            ProgressView(value: elapsed, total: totalSeconds)
                .tint(.green)
                .padding(.horizontal)
            
            Text("\(grownTrees) / \(treeCount) trees")
                .font(.headline)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(0..<treeCount, id: \.self) { index in
                        Text(emoji(for: index))
                            .font(.system(size: 40))
                            .opacity(index > grownTrees ? 0.25 : 1)
                            .animation(.spring, value: grownTrees)
                    }
                }
                .padding()
            }
            
            Button(isFinished ? "Done" : "Give Up") {
                
                dismiss()
            }
            .buttonStyle(.bordered)
            .tint(isFinished ? .green : .red)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            startDate = Date()
            now = startDate
            
        }
        .onDisappear {
            
        }
        .onReceive(timer) { time in
            guard !isFinished else { return }
            now = time
        }
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
    
    #Preview {
        ContentView()
    }
}

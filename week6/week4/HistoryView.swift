import SwiftUI

// page 3: all past planting sessions
struct HistoryView: View {
    @Environment(Document.self) var document

    var body: some View {
        List {
            Section {
                Text("🌳 \(document.totalTrees) trees grown")
                    .font(Font.custom(fontName, size: 24))
            }

            if document.records.isEmpty {
                Text("No trees yet. Go plant some!")
                    .font(Font.custom(fontName, size: 16))
                    .foregroundStyle(.gray)
            }

            // newest first
            ForEach(document.records.reversed()) { record in
                VStack(alignment: .leading, spacing: 6) {
                    Text(record.completed ? "🌳 Completed" : "🥀 Gave Up")
                        .font(Font.custom(fontName, size: 18))

                    Text("\(record.grownTrees) / \(record.treeCount) trees")
                        .font(Font.custom(fontName, size: 16))

                    Text(record.date.formatted(date: .abbreviated, time: .shortened))
                        .font(Font.custom(fontName, size: 13))
                        .foregroundStyle(.gray)
                }
            }
        }
        .navigationTitle("My Forest")
        .toolbar {
            Button("Clear") {
                document.clear()
            }
            .disabled(document.records.isEmpty)
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
    .environment(Document())
}

import Foundation

// all the data we want to save
struct Model: Codable {
    var records: [PlantRecord] = []

    mutating func addRecord(_ record: PlantRecord) {
        records.append(record)
    }

    mutating func reset() {
        records = []
    }
}

// one planting session
struct PlantRecord: Identifiable, Codable {
    var id = UUID()
    var date = Date()
    var treeCount: Int      // how many trees were planned
    var grownTrees: Int     // how many actually grew
    var completed: Bool     // true = Done, false = Give Up
}

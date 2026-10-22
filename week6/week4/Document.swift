import SwiftUI

// connects the Model to the views
@Observable class Document {
    var model: Model
    let fileName = "forest.json"

    // load saved records when the app starts
    init() {
        model = Model(JSONfileName: fileName)
    }

    var records: [PlantRecord] {
        model.records
    }

    // total trees grown across all sessions
    var totalTrees: Int {
        model.records.reduce(0) { $0 + $1.grownTrees }
    }

    // add a record and save right away
    func addRecord(treeCount: Int, grownTrees: Int, completed: Bool) {
        let record = PlantRecord(treeCount: treeCount, grownTrees: grownTrees, completed: completed)
        model.addRecord(record)
        save()
    }

    func clear() {
        model.reset()
        save()
    }

    func save() {
        model.saveAsJSON(fileName: fileName)
    }
}

import Foundation

// save and load the Model as a JSON file
extension Model {

    func saveAsJSON(fileName: String) {
        do {
            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileUrl = directory.appendingPathComponent(fileName)
            print("saveAsJSON filePath \(fileUrl)")

            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            let jsonData = try encoder.encode(self)
            try jsonData.write(to: fileUrl)
        } catch {
            print("Model saveAsJSON error \(error)")
        }
    }

    init(JSONfileName fileName: String) {
        records = []
        do {
            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileUrl = directory.appendingPathComponent(fileName)

            // first launch: no file yet, start empty
            if !FileManager.default.fileExists(atPath: fileUrl.path) {
                print("Model init no file yet \(fileUrl)")
                return
            }
            print("Model init filePath \(fileUrl)")

            let jsonData = try Data(contentsOf: fileUrl)
            let decoder = JSONDecoder()
            self = try decoder.decode(Model.self, from: jsonData)
        } catch {
            print("Model init error \(error)")
        }
    }
}

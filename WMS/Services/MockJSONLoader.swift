import Foundation

enum MockJSONLoader {
    static func decode<T: Decodable>(_ type: T.Type, from fileName: String) throws -> T {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw MockJSONLoaderError.fileNotFound(fileName)
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}

enum MockJSONLoaderError: Error {
    case fileNotFound(String)
}

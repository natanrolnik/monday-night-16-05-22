import Foundation

private let jsonEncoder = JSONEncoder()

extension Encodable {
    var asJSONString: String {
        get throws {
            String(data: try jsonEncoder.encode(self), encoding: .utf8) ?? ""
        }
    }
}

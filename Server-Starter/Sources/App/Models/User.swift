import Fluent
import Vapor
import Shared

final class User: Model, Content {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "email")
    var email: String?

    init() {}

    init(id: UUID? = nil, name: String, email: String?) {
        self.id = id
        self.name = name
        self.email = email
    }
}

extension User {
    var asPublic: Shared.User {
        get throws {
            .init(id: try requireID(), name: name, email: email)
        }
    }
}

extension Array where Element == User {
    var asPublic: [Shared.User] {
        get throws {
            try map { try $0.asPublic }
        }
    }
}

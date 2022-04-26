import Foundation

public struct User: Codable {
    public let id: UUID
    public let name: String
    public let email: String?

    public init(id: UUID,
                name: String,
                email: String?) {
        self.id = id
        self.name = name
        self.email = email
    }
}

public struct UsersResponse: Codable {
    public let users: [User]

    public init(users: [User]) {
        self.users = users
    }
}

public struct UserResponse: Codable {
    public let user: User

    public init(user: User) {
        self.user = user
    }
}

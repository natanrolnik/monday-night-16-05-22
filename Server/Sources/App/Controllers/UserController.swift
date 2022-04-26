import Fluent
import Vapor
import Shared

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(use: index)
        users.post("new", use: create)
    }

    private func index(req: Request) async throws -> UsersResponse {
        let users = try await User.query(on: req.db).all()
        return .init(users: try users.asShared)
    }

    private func create(req: Request) async throws -> UserResponse {
        let user = try req.content.decode(User.self)
        try await user.save(on: req.db)
        return .init(user: try user.asShared)
    }
}

extension Shared.User: Content {}
extension UserResponse: Content {}
extension UsersResponse: Content {}

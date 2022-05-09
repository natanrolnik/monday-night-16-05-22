import Fluent
import Vapor
import Shared

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("users") // example.com/users/...

        // POST example.com/users/new
        usersRoute.post("new", use: create)

        // GET example.com/users
        usersRoute.get(use: allUsers)
    }

    private func allUsers(req: Request) async throws -> UsersResponse {
        let users = try await User.query(on: req.db).all()
        return UsersResponse(users: try users.asPublic)
    }

    private func create(req: Request) async throws -> UserResponse {
        let user = try req.content.decode(User.self)
        try await user.save(on: req.db)
        return UserResponse(user: try user.asPublic)
    }
}

extension Shared.User: Content {}
extension UserResponse: Content {}
extension UsersResponse: Content {}

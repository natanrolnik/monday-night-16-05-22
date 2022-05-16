import Vapor
import Fluent
import Shared
---

struct UserController: RouteCollection {

}
---

func boot(routes: RoutesBuilder) throws {

}
---

private func create(req: Request) async throws -> UserResponse {

}
---

let user = try req.content.decode(User.self)
try await user.save(on: req.db)
return UserResponse(user: try user.asPublic)
---

private func allUsers(req: Request) async throws -> UsersResponse {

}
---

let users = try await User.query(on: req.db).all()
return UsersResponse(users: try users.asPublic)
---

// example.com/users/...
let users = routes.grouped("users")
---

// GET example.com/users
users.get(use: allUsers)
---

// POST example.com/users/new
users.post("new", use: create) 
---

extension Shared.User: Content {}
extension UserResponse: Content {}
extension UsersResponse: Content {}
---

try app.register(collection: UserController())
---

let userId = try req.userId
---

guard let user = try await User.query(on: req.db)
	.filter(\.$id == userId)
	.first() else {
	throw Abort(.badRequest)
}
---

async let currentCount = try await get(key: "goals-count:user:\(userId)", on: req, increment: true)
async let todayCount = try await get(key: redisTodayKey, on: req, increment: true)
---

let summary = try await GoalsSummary(today: todayCount).asJSONString
liveSockets.send(summary)
---

return try await UserGoals(user: try user.asPublic, count: currentCount)
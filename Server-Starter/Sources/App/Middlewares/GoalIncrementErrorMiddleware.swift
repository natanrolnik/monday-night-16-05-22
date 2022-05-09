import Vapor
import Fluent

struct GoalIncrementErrorMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let response = try await next.respond(to: request)

        if request.method == .PUT,
           request.url.path == "/goals/increment",
           response.status == .notImplemented,
           let userId = try? request.userId {

            if let user = try await User.query(on: request.db)
                .filter(\.$id == userId)
                .first() {
                request.logger.notice("Goal increment tried by \(user.name), but it's not implemented yet")
            }
        }

        return response
    }
}

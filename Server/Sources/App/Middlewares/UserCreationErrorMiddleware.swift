import Vapor

struct ErrorResponse: Codable {
    let error: Bool
    let reason: String
}

struct UserCreationErrorMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let response = try await next.respond(to: request)

        if request.method == .POST,
           request.url.path == "/users/new",
           response.status == .notFound,
           let user = try? request.content.decode(User.self) {
            let reason = "Hold on, \(user.name). This method doesn't exist yet, therefore you see a 404. We'll implement it right now."
            let errorResponse = ErrorResponse(error: true, reason: reason)
            response.body = try .init(data: JSONEncoder().encode(errorResponse))
            request.logger.notice("User creation tried by \(user.name), but it's not ready yet")
        }

        return response
    }
}

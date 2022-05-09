import Vapor

struct UserCreationErrorMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let response = try await next.respond(to: request)

        if request.method == .POST,
           request.url.path == "/users/new",
           response.status == .notFound,
           let user = try? request.content.decode(User.self) {
            request.logger.notice("User creation tried by \(user.name), but it's not ready yet")
        }

        return response
    }
}

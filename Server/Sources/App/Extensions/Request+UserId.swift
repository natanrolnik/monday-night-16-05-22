import Vapor

extension Request {
    var userId: UUID {
        get throws {
            // This is **not** how authorization should be done
            // in any way.
            // It's here only for example purposes.

            guard let headerValue = headers.first(name: "X-Nutmeg-User-Id"),
                  let userId = UUID(uuidString: headerValue) else {
                throw Abort(.unauthorized)
            }

            return userId
        }
    }
}

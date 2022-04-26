import Fluent
import Vapor
import Shared

struct RaffleController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let raffle = routes.grouped("raffle")
        raffle.get(use: selectRandomUser)
    }

    private func selectRandomUser(req: Request) async throws -> UserResponse {
        let users = try await User.query(on: req.db).all()
        guard let user = users.randomElement() else {
            throw Abort(.internalServerError)
        }

        //TODO: update socket

        return .init(user: try user.asShared)
    }
}

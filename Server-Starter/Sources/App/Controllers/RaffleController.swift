import Fluent
import Vapor
import Shared

class RaffleController: RouteCollection {
    private var raffleStatus = RaffleStatus.idle {
        didSet {
            guard let status = try? raffleStatus.asJSONString else {
                return
            }

            liveSockets.send(status)
        }
    }

    private var liveSockets = WebSocketsWrapper()

    func boot(routes: RoutesBuilder) throws {
        let raffle = routes.grouped("raffle")
        raffle.post("start", use: start)

        raffle.webSocket("live") { [weak self] _, ws in
            guard let self = self else {
                return
            }

            try? ws.send(self.raffleStatus.asJSONString)
            self.liveSockets.register(ws)
        }
    }

    private func start(req: Request) async throws -> Response {
        guard raffleStatus.isIdle else {
            throw Abort(.badRequest)
        }

        raffleStatus = .started

        let users = try await User.query(on: req.db).all()
        let limit = 20
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.25) {
            self.chooseRandomUser(from: users, index: 0, limit: limit)
        }

        return Response()
    }

    private func chooseRandomUser(from users: [User], index: Int, limit: Int) {
        guard let user = users.randomElement() else {
            return
        }

        if index < limit {
            self.raffleStatus = .running(candidate: user.name, color: Color.palette.randomElement()!)
            DispatchQueue.global().asyncAfter(deadline: .now() + (0.25 + (Double(index) * 0.02))) {
                self.chooseRandomUser(from: users, index: index + 1, limit: limit)
            }
        } else {

            self.raffleStatus = .running(candidate: user.name, color: Color.palette.randomElement()!)

            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                self.raffleStatus = .finished(winner: try! user.asPublic, color: Color.winnerGreen)

                DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                    self.raffleStatus = .idle
                }
            }
        }
    }
}

extension RaffleStatus: Content {}
extension RaffleStatusPayload: Content {}

extension Color {
    static let winnerGreen = Color(26, 188, 156)

    static let palette: [Color] = [
        .init(52, 152, 219),
        .init(142, 68, 173),
        .init(189, 195, 199),
        .init(241, 196, 15),
        .init(253, 121, 168),
        .init(255, 177, 66),
        .init(255, 82, 82)
    ]
}

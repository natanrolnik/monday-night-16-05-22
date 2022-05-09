import Fluent
import Vapor
import Shared
import RediStack

// Storing the goals count per user could be done with the existing
// Postgres database. Using Redis is purely for demonstration purposes.

class GoalController: RouteCollection {
    private let redisTodayKey: RedisKey = "goals-count:general:today"

    private var liveSockets = WebSocketsWrapper()

    func boot(routes: RoutesBuilder) throws {
        let goalsRoute = routes.grouped("goals")
        goalsRoute.get("summary", use: summary)
        goalsRoute.put("increment", use: increment)
        goalsRoute.get("ranking", use: ranking)

        goalsRoute.webSocket("live") { [weak self] _, ws in
            self?.liveSockets.register(ws)
        }
    }

    private func summary(req: Request) async throws -> GoalsSummary {
        let count = try await req.redis.get(redisTodayKey, as: Int.self).get() ?? 0
        return GoalsSummary(today: count)
    }

    private func increment(req: Request) async throws -> UserGoals {
        throw Abort(.notImplemented,
                    reason: "We will implement it together in a few minutes!")
    }

    private func get(key: RedisKey, on req: Request, increment: Bool = false) async throws -> Int {
        var count = try await req.redis.get(key, as: Int.self).get() ?? 0

        if increment {
            count += 1
            try await req.redis.set(key, to: count).get()
        }

        return count
    }

    private func ranking(req: Request) async throws -> Ranking {
        let keys = try await req.redis.scan(matching: "goals-count:user:*", count: 200).get().1

        let userIds = keys.compactMap(\.userId)

        let redisKeys = keys.map { RedisKey(stringLiteral: $0) }
        let goals = try await req.redis.mget(redisKeys).get()
        let pairs = keys.enumerated().reduce(into: [UUID: Int]()) { result, element in
            guard let uuid = element.element.userId,
                  goals.indices.contains(element.offset) else {
                return
            }

            result[uuid] = goals[element.offset].int
        }

        let users = try await User.query(on: req.db)
            .filter(\.$id ~~ userIds)
            .all()

        let strikers = users.compactMap { user -> UserGoals? in
            guard let user = try? user.asPublic,
                  let count = pairs[user.id] else {
                return nil
            }

            return UserGoals(user: user, count: count)
        }.sorted { $0.count > $1.count }

        return Ranking(strikers: strikers)
    }
}

private extension String {
    var userId: UUID? {
        guard let uuidString = components(separatedBy: ":").last,
              let uuid = UUID(uuidString: uuidString) else {
            return nil
        }

        return uuid
    }
}

extension GoalsSummary: Content {}
extension UserGoals: Content {}
extension Ranking: Content {}

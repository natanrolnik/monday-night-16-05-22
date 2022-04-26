import Fluent
import Vapor
import Shared
import RediStack

// Storing the nutmegs count per user could be done with the existing
// Postgres database. Using Redis is purely for demonstration purposes.

class NutmegController: RouteCollection {
    private let redisTodayKey: RedisKey = "nutmeg-count:general:today"

    private var liveSockets = WebSocketsWrapper()

    func boot(routes: RoutesBuilder) throws {
        let nutmegs = routes.grouped("nutmegs")
        nutmegs.get("summary", use: summary)
        nutmegs.put("increment", use: increment)
        nutmegs.get("ranking", use: ranking)

        nutmegs.webSocket("live") { [weak self] _, ws in
            self?.liveSockets.register(ws)
        }
    }

    private func summary(req: Request) async throws -> NutmegsSummary {
        let count = try await req.redis.get(redisTodayKey, as: Int.self).get() ?? 0
        return .init(today: count)
    }

    private func increment(req: Request) async throws -> UserNutmegs {
        let userId = try req.userId

        guard let user = try await User.query(on: req.db)
            .filter(\.$id == userId)
            .first() else {
            throw Abort(.badRequest)
        }

        async let currentCount = try await get(key: "nutmeg-count:user:\(userId)", on: req, increment: true)
        async let todayCount = try await get(key: redisTodayKey, on: req, increment: true)

        let summary = try await NutmegsSummary(today: todayCount).asJSONString
        liveSockets.send(summary)

        return try await .init(user: try user.asPublic, count: currentCount)
    }

    private func get(key: RedisKey, on req: Request, increment: Bool = false) async throws -> Int {
        var count = try await req.redis.get(key, as: Int.self).get() ?? 0

        if increment {
            count += 1
            try await req.redis.set(key, to: count).get()
        }

        return count
    }

    private func ranking(req: Request) async throws -> NutmegsRanking {
        let keys = try await req.redis.scan(matching: "nutmeg-count:user:*", count: 200).get().1

        let userIds = keys.compactMap(\.userId)

        let nutmegs = try await req.redis.mget(keys.map(RedisKey.init(stringLiteral:))).get()
        let pairs = keys.enumerated().reduce(into: [UUID: Int]()) { result, element in
            guard let uuid = element.element.userId,
                  nutmegs.indices.contains(element.offset) else {
                return
            }

            result[uuid] = nutmegs[element.offset].int
        }

        let users = try await User.query(on: req.db)
            .filter(\.$id ~~ userIds)
            .all()

        let ranking = users.compactMap { user -> UserNutmegs? in
            guard let user = try? user.asPublic,
                  let count = pairs[user.id] else {
                return nil
            }

            return UserNutmegs(user: user, count: count)
        }.sorted { $0.count > $1.count }
        return .init(ranking: ranking)
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

extension NutmegsSummary: Content {}
extension UserNutmegs: Content {}
extension NutmegsRanking: Content {}

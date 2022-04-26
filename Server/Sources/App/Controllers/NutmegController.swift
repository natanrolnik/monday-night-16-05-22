import Fluent
import Vapor
import Shared
import RediStack

// Storing the nutmegs count per user could be done with the existing
// Postgres database. Using Redis is purely for demonstration purposes.

struct NutmegController: RouteCollection {
    private let redisTodayKey: RedisKey = "nutmeg-count:general:today"

    func boot(routes: RoutesBuilder) throws {
        let nutmegs = routes.grouped("nutmegs")
        nutmegs.get("today", use: today)
        nutmegs.put("increment", use: increment)
        nutmegs.get("ranking", use: ranking)
    }

    private func today(req: Request) async throws -> NutmegsToday {
        let count = try await req.redis.get(redisTodayKey, as: Int.self).get() ?? 0
        return .init(count: count)
    }

    private func increment(req: Request) async throws -> NutmegsCount {
        let userId = try req.userId
        let redisKey: RedisKey = "nutmeg-count:user:\(userId)"

        guard let user = try await User.query(on: req.db)
            .filter(\.$id == userId)
            .first() else {
            throw Abort(.badRequest)
        }

        var currentCount = try await req.redis.get(redisKey, as: Int.self).get() ?? 0
        currentCount += 1
        try await req.redis.set(redisKey, to: currentCount).get()

        var todayCount = try await req.redis.get(redisTodayKey, as: Int.self).get() ?? 0
        todayCount += 1
        try await req.redis.set(redisTodayKey, to: todayCount).get()

        print("Today count is \(todayCount)")

        //TODO: update today count via socket


        return .init(user: try user.asShared, count: currentCount)
    }

    private func ranking(req: Request) async throws -> NutmegsRanking {
//        let a = try await req.redis.
        throw Abort(.notImplemented)
    }
}

extension NutmegsToday: Content {}
extension NutmegsCount: Content {}
extension NutmegsRanking: Content {}

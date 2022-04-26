import Fluent
import Vapor
import Shared

struct NutmegController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let nutmegs = routes.grouped("nutmegs")
        nutmegs.get("today", use: today)
        nutmegs.post("increment", use: increment)
        nutmegs.get("ranking", use: ranking)
    }

    private func today(req: Request) async throws -> NutmegsToday {
        throw Abort(.notImplemented)
    }

    private func increment(req: Request) async throws -> NutmegsCount {
        //TODO: update socket
        throw Abort(.notImplemented)
    }

    private func ranking(req: Request) async throws -> NutmegsRanking {
        throw Abort(.notImplemented)
    }
}

extension NutmegsToday: Content {}
extension NutmegsCount: Content {}
extension NutmegsRanking: Content {}

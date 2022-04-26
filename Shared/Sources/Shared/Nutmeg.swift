import Foundation

public struct NutmegsCount: Codable {
    public let user: User
    public let count: Int

    public init(user: User, count: Int) {
        self.user = user
        self.count = count
    }
}

public struct NutmegsToday: Codable {
    public let count: Int

    public init(count: Int) {
        self.count = count
    }
}

public struct NutmegsRanking: Codable {
    public let ranking: [NutmegsCount]

    public init(ranking: [NutmegsCount]) {
        self.ranking = ranking
    }
}

import Foundation

public struct UserNutmegs: Codable {
    public let user: User
    public let count: Int

    public init(user: User, count: Int) {
        self.user = user
        self.count = count
    }
}

public struct NutmegsSummary: Codable {
    public let today: Int

    public init(today: Int) {
        self.today = today
    }
}

public struct NutmegsRanking: Codable {
    public let ranking: [UserNutmegs]

    public init(ranking: [UserNutmegs]) {
        self.ranking = ranking
    }
}

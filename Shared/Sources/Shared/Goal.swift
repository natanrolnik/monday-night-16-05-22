import Foundation

public struct UserGoals: Codable {
    public let user: User
    public let count: Int

    public init(user: User, count: Int) {
        self.user = user
        self.count = count
    }
}

public struct GoalsSummary: Codable {
    public let today: Int

    public init(today: Int) {
        self.today = today
    }
}

public struct Ranking: Codable {
    public let strikers: [UserGoals]

    public init(strikers: [UserGoals]) {
        self.strikers = strikers
    }
}

import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }

    try app.register(collection: GoalController())
    try app.register(collection: RaffleController())
//    try app.register(collection: UserController())
}

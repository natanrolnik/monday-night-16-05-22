import Fluent
import FluentPostgresDriver
import Leaf
import Vapor
import Redis

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // cors middleware should come before default error middleware using `at: .beginning`
    let config = CORSMiddleware.Configuration(
        allowedOrigin: .originBased,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .init("X-Nutmeg-User-Id")]
    )
    app.middleware.use(CORSMiddleware(configuration: config), at: .beginning)

    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql)

    app.redis.configuration = try RedisConfiguration(hostname: "localhost")

    app.migrations.add(CreateUser())

    try app.autoMigrate().wait()

    // register routes
    try routes(app)
}

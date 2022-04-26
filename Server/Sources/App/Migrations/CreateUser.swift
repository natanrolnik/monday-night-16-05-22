import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(User.schema)
            .id()
            .field("name", .string, .required)
            .field("email", .string)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(User.schema).delete()
    }
}

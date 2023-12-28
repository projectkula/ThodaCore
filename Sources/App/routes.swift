import Fluent
import Vapor
import GraphQLKit

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    app.register(graphQLSchema: schema, withResolver: Resolver.instance)
    
    // Auth controllers
    try app.register(collection: SignupController())
    try app.register(collection: LoginController())
    try app.register(collection: RefreshController())
    try app.register(collection: GoogleController())
}

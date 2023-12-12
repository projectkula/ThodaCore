//
//  AuthController.swift
//
//
//  Created by Shrish Deshpande on 11/12/23.
//

import Vapor
import Fluent
import Smtp

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        
        auth.group("login") { e in
            e.post(use: initialAuth)
            e.get(use: methodNotAllowed)
        }
        
        auth.group("signup") { e in
            e.post(use: initialSignup)
            e.get(use: methodNotAllowed)
        }
    }
    
    func initialAuth(req: Request) async throws -> AuthResponseBody {
        let params: LoginAuthRequest
        
        do {
            params = try req.content.decode(LoginAuthRequest.self)
        } catch {
            throw Abort(.badRequest, reason: "Invalid request: \(error.localizedDescription)")
        }
        
        throw Abort(.notImplemented, reason: "we have no users yet \(params.id)")
    }
    
    func initialSignup(req: Request) async throws -> SignupCodeResponseBody {
        let args: GetUserArgs
        
        do {
            args = try req.content.decode(GetUserArgs.self)
        } catch {
            throw Abort(.badRequest, reason: "Invalid request: \(error.localizedDescription)")
        }
        
        let user = try await Resolver.instance.getUser(request: req, arguments: args).get()
        
        if await (try RegisteredUser.query(on: req.db).filter(\.$id == args.id).first() != nil) {
            throw Abort(.conflict, reason: "User already exists")
        }
        
        let email = try Email(
            from: EmailAddress(address: thodaCoreEmail, name: "Thoda Core"),
            to: [EmailAddress(address: user.email, name: user.name)],
            subject: "Your verification code",
            body: "haha not implemented lol")
        
        let sent = try await req.smtp.send(email) { message in
            req.application.logger.info("\(message)")
        }.get()
        let result: Bool
        
        do {
            result = try sent.get()
        } catch {
            throw Abort(.internalServerError, reason: "Failed to send email: \(error.localizedDescription)")
        }
        
        return SignupCodeResponseBody(success: result)
    }
    
    func methodNotAllowed(req: Request) async throws -> AuthResponseBody {
        throw Abort(.methodNotAllowed)
    }
}

struct LoginAuthRequest: Content {
    let id: String
    let pw: String
}

struct AuthResponseBody: Content {
    let accessToken: String
    let refreshToken: String
}

struct SignupCodeResponseBody: Content {
    let success: Bool
}
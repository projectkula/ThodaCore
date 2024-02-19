//
//  Resolver+GetConfessions.swift
//
//
//  Created by Shrish Deshpande on 19/02/24.
//

import Graphiti
import Fluent
import Vapor

extension Resolver {
    func getConfessions(request: Request, arguments: PaginationArgs) async throws -> Page<Confession> {
        try await verifyAccessToken(req: request)
        return try await Confession.query(on: request.db)
            .paginate(.init(page: arguments.page, per: arguments.per))
    }
}
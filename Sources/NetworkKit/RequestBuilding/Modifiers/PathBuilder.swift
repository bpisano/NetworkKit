//
//  PathBuilder.swift
//  NetworkKit
//
//  Created by Benjamin Pisano on 07/07/2025.
//

import Foundation

struct PathBuilder: RequestModifier {
    let request: any HttpRequest

    func modify(_ urlRequest: inout URLRequest) throws {
        try request.pathParameters.forEach { pathParameter in
            try pathParameter.modify(&urlRequest)
        }
    }
}

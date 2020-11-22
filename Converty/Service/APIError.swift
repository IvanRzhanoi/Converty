//
//  APIError.swift
//  Converty
//
//  Created by Ivan Rzhanoi on 22.11.2020.
//

import Foundation


enum APIError: Error, LocalizedError {
    case unknown, apiError(reason: String), parserError(reason: String), unauthorized
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case .apiError(let reason), .parserError(let reason):
            return reason
        case .unauthorized:
            return "Unauthorized"
        }
    }
}

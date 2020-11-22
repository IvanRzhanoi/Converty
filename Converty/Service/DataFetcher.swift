//
//  DataFetcher.swift
//  Converty
//
//  Created by Ivan Rzhanoi on 22.11.2020.
//

import Foundation
import Combine


class DataFetcher {

    let decoder = JSONDecoder()
    
    // Used for basic fetching of response
    func fetch(request: URLRequest) -> AnyPublisher<Data, APIError> {
        return URLSession.DataTaskPublisher(request: request, session: .shared)
            .tryMap { data, response in
                
                // Useless to check for response with this API, because most of errors will be sent through the body and not the status of response
                // Even when failing to use source, the status code is still 200
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    print("Error httpResponse: \(response)")
//                    throw APIError.unknown
//                }
//                if httpResponse.statusCode == 105 {
//                    throw APIError.unauthorized
//                }
                
//                print("data: \(data); response: \(httpResponse)")

                let myResponse = try self.decoder.decode(Response.self, from: data)
                
                if myResponse.error?.code == 105 {
                    throw APIError.unauthorized
                }
                
                return data
            }
            .mapError { error in
                if let error = error as? APIError {
                    return error
                } else {
                    return APIError.apiError(reason: error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }


    // Used for decoding
    func fetch<T: Decodable>(request: URLRequest) -> AnyPublisher<T, APIError> {
        fetch(request: request)
            .decode(type: T.self, decoder: decoder)
            .mapError { error in
                if let error = error as? DecodingError {
                    var errorToReport = error.localizedDescription
                    switch error {
                    case .dataCorrupted(let context):
                        let details = context.underlyingError?.localizedDescription ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                        errorToReport = "\(context.debugDescription) - (\(details))"
                    case .keyNotFound(let key, let context):
                        let details = context.underlyingError?.localizedDescription ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                        errorToReport = "\(context.debugDescription) (key: \(key), \(details))"
                    case .typeMismatch(let type, let context), .valueNotFound(let type, let context):
                        let details = context.underlyingError?.localizedDescription ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                        errorToReport = "\(context.debugDescription) (type: \(type), \(details))"
                    @unknown default:
                        break
                    }
                    return APIError.parserError(reason: errorToReport)
                }  else {
                    return APIError.apiError(reason: error.localizedDescription)
                }
        }
        .eraseToAnyPublisher()
    }
}

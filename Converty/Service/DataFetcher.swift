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
    // TODO: Delete cancellables after testing
    var cancellables = Set<AnyCancellable>()

    
    // Used for basic fetching of response
    func fetch(request: URLRequest) -> AnyPublisher<Data, APIError> {
        var request = request
        request.setValue("3", forHTTPHeaderField: "X-Ecolane-Version")
        request.setValue("ASKVFKL123ASFK542TIJF1KFJKAKA", forHTTPHeaderField: "X-Ecolane-Token")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // This key matches the one in Flutter
//        if let agencyEndpoint = Repository.getAgencyEndPoint() {
//            request.setValue(agencyEndpoint, forHTTPHeaderField: "X-Ecolane-System-ID")
//        }

        // This key matches the one in Flutter
//        if let jwt = Repository.getToken() {
//            request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
//        }
//        print("\(Date()) jsonWebToken: \(String(describing: jsonWebToken))")
//        print("_________________my request: \(request.allHTTPHeaderFields)")

        return URLSession.DataTaskPublisher(request: request, session: .shared)
            .tryMap { data, response in
                // TODO: Throw out pop-up with an error message
                //print("I am fetching the data at: \(Date())")
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Error httpResponse: \(response)")
                    throw APIError.unknown
                }

//                if httpResponse.statusCode == 400 {
//                    print(data)
//                    let string = String(data: data, encoding: .utf8)!
//                    print("Status code 400. Response: \(string)")
//
//                    let myResponse = try JSONDecoder().decode(Response.self, from: data)
//                    print("PasswordChangeRequired: \(myResponse.passwordChangeRequired ?? false)")
//                    print("Message: \(myResponse.message ?? "no message")")
//
//                    throw APIError.apiError(reason: myResponse.message ?? "No message")
//                }

                if httpResponse.statusCode == 401 {
                    print(data)
                    let string = String(data: data, encoding: .utf8)!
                    print("Status code 401. Response: \(string)")

//                    let myResponse = try JSONDecoder().decode(Response.self, from: data)
//                    print("PasswordChangeRequired: \(myResponse.passwordChangeRequired ?? false)")
//                    print("Message: \(myResponse.message ?? "no message")")

                    throw APIError.unauthorized
                }

                guard 200..<300 ~= httpResponse.statusCode else {
                    print("HTTP response is NOT between 200 and 300: \(httpResponse.statusCode)")
                    //dump(httpResponse)
                    throw APIError.unknown
                }
//                print("_________________ response: \(response)")
//                print("_________________ data: \(data)")
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

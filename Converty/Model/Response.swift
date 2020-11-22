//
//  Response.swift
//  Converty
//
//  Created by Ivan Rzhanoi on 22.11.2020.
//

import Foundation


struct Response: Decodable {
    let success: Bool?
    let error: ResponseError?
    let source: String?
    let quotes: [String: Double]?
    let currencies: [String: String]?
}

struct ResponseError: Decodable {
    let code: Int?
    let info: String?
}

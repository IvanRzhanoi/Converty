//
//  Currency.swift
//  Converty
//
//  Created by Ivan Rzhanoi on 22.11.2020.
//

import Foundation


struct Currency: Decodable, Identifiable {
    var id = UUID()
    var source: String? // Currency code like USD for US Dollar
    var name: String?
    var timestamp: Date? // Used to track the last time of update
    var quotes: [String: Double]?
}

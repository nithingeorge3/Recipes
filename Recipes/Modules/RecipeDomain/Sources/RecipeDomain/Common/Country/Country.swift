//
//  Country.swift
//  RecipeDomain
//
//  Created by Nitin George on 03/03/2025.
//

import Foundation

public enum Country: String, Codable {
    case us = "US"
    case ind = "IND"
    case gb = "GB"
    case pl = "PL" //we can add more here
    case unknown
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Country(rawValue: rawValue) ?? .unknown
    }
}

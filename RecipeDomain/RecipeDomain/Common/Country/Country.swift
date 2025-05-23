//
//  Country.swift
//  RecipeDomain
//
//  Created by Nitin George on 03/03/2025.
//

import Foundation

@frozen
public enum Country: String, Codable {
    case us = "US"
    case ind = "IND"
    case gb = "GB"
    case pl = "PL"
    case unknown
}

//
//  RecipeDTO.swift
//  RecipeNetworking
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation

public struct RecipeDomain: Identifiable, @unchecked Sendable {
    public var id: Int
    public var name: String
    public var country: Country
    public var description: String?
    public var thumbnailURL: String?
    public var originalVideoURL: String?
    public var createdAt, approvedAt: Int?
    public var yields: String?
    public var isFavorite: Bool
    public var ratings: UserRatingsDomain?
    
    public init(id: Int, name: String, description: String? = nil, country: Country = .unknown, thumbnailURL: String? = nil, originalVideoURL: String? = nil, createdAt: Int? = nil, approvedAt: Int? = nil, yields: String? = nil, isFavorite: Bool = false, ratings: UserRatingsDomain? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.country = country
        self.thumbnailURL = thumbnailURL
        self.originalVideoURL = originalVideoURL
        self.createdAt = createdAt
        self.approvedAt = approvedAt
        self.yields = yields
        self.isFavorite = isFavorite
        self.ratings = ratings
    }
}

public struct UserRatingsDomain: Codable {
    public let id: Int
    public var countNegative, countPositive: Int
    public var score: Double
    
    public init(id: Int, countNegative: Int = 0, countPositive: Int = 0, score: Double = 0) {
        self.id = id
        self.countNegative = countNegative
        self.countPositive = countPositive
        self.score = score
    }
}

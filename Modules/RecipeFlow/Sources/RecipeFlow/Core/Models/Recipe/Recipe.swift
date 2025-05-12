//
//  Recipe.swift
//  Recipes
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation
import RecipeDomain

public struct Recipe: Identifiable, Hashable {
    public let id: Int
    public let name: String
    public let country: Country
    public let description: String?
    public let thumbnailURL: String?
    public let originalVideoURL: String?
    public let createdAt, approvedAt: Int?
    public let yields: String?
    public var isFavorite: Bool = false
    public let ratings: UserRatings

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id
    }
    
    init(id: Int, name: String, description: String? = nil, country: Country = .unknown, thumbnailURL: String? = nil, originalVideoURL: String? = nil, createdAt: Int? = nil, approvedAt: Int? = nil, yields: String? = nil, isFavorite: Bool = false, ratings: UserRatings) {
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

extension Recipe {
    init(from recipeDomain: RecipeDomain) {
        let ratings = UserRatings(from: recipeDomain.ratings)
        
        self.id = recipeDomain.id
        self.name = recipeDomain.name
        self.description = recipeDomain.description
        self.country = recipeDomain.country
        self.thumbnailURL = recipeDomain.thumbnailURL
        self.originalVideoURL = recipeDomain.originalVideoURL
        self.createdAt = recipeDomain.createdAt
        self.approvedAt = recipeDomain.approvedAt
        self.yields = recipeDomain.yields
        self.isFavorite = recipeDomain.isFavorite
        self.ratings = ratings
    }
}

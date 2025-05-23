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
    
    public init(id: Int, name: String, description: String? = nil, country: Country = .unknown, thumbnailURL: String? = nil, originalVideoURL: String? = nil, createdAt: Int? = nil, approvedAt: Int? = nil, yields: String? = nil, isFavorite: Bool = false, ratings: UserRatings) {
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

public extension Recipe {
    init(from recipe: RecipeModel) {
        let ratings = UserRatings(from: recipe.ratings)
        
        self.id = recipe.id
        self.name = recipe.name
        self.description = recipe.description
        self.country = recipe.country
        self.thumbnailURL = recipe.thumbnailURL
        self.originalVideoURL = recipe.originalVideoURL
        self.createdAt = recipe.createdAt
        self.approvedAt = recipe.approvedAt
        self.yields = recipe.yields
        self.isFavorite = recipe.isFavorite
        self.ratings = ratings
    }
}

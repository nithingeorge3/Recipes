//
//  SDRecipe.swift
//  RecipeDataStore
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation
import SwiftData
import RecipeDomain

@Model
public final class SDRecipe {
    @Attribute(.unique)
    public var id: Int
    public var name: String
    public var desc: String?
    public var country: Country // For filtering by country we need to use/save as transformable. or use row and string value(same as SDPagination entityTypeRaw)
    public var thumbnailURL: String?
    public var originalVideoURL: String?
    public var createdAt: Int?
    public var approvedAt: Int?
    public var yields: String?
    public var isFavorite: Bool
    
    @Relationship(deleteRule: .cascade, inverse: \SDUserRatings.recipe)
    public var ratings: SDUserRatings?
    
    init(
        id: Int,
        name: String,
        desc: String? = nil,
        country: Country = .unknown,
        thumbnailURL: String? = nil,
        originalVideoURL: String? = nil,
        createdAt: Int? = nil,
        approvedAt: Int? = nil,
        yields: String? = nil,
        isFavorite: Bool,
        ratings: SDUserRatings? = nil
    ) {
        let ratings = SDUserRatings(
            id: ratings?.id,
            countNegative: ratings?.countNegative,
            countPositive: ratings?.countPositive,
            score: ratings?.score
        )
        
        self.id = id
        self.name = name
        self.desc = desc
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

extension SDRecipe {
    convenience init(from recipe: RecipeDomain) {
        let ratings = SDUserRatings(from: recipe.ratings)
        
        self.init(
            id: recipe.id,
            name: recipe.name,
            desc: recipe.description,
            country: recipe.country,
            thumbnailURL: recipe.thumbnailURL,
            originalVideoURL: recipe.originalVideoURL,
            createdAt: recipe.createdAt,
            approvedAt: recipe.approvedAt,
            yields: recipe.yields,
            isFavorite: recipe.isFavorite,
            ratings: ratings
            )
    }
    
    //Not updating isFavorite because we are not fetching isFavorite from backend
    func update(from domain: RecipeDomain) {
        self.id = domain.id
        self.name = domain.name
        self.desc = domain.description
        self.country = domain.country
        self.thumbnailURL = domain.thumbnailURL
        self.originalVideoURL = domain.originalVideoURL
        self.createdAt = domain.createdAt
        self.approvedAt = domain.approvedAt
        self.yields = domain.yields
         
        // Handle ratings update
        if let domainRatings = domain.ratings {
            if let existing = self.ratings {
                existing.countPositive = domainRatings.countPositive
                existing.countNegative = domainRatings.countNegative
                existing.score = domainRatings.score
            } else {
                self.ratings = SDUserRatings(from: domainRatings)
            }
        } else {
            self.ratings = nil
        }
    }
}

extension RecipeDomain {
    init(from sdRecipe: SDRecipe) {
        let ratings = UserRatingsDomain(id: sdRecipe.ratings?.id ?? 0, countNegative: sdRecipe.ratings?.countNegative ?? 0, countPositive: sdRecipe.ratings?.countPositive ?? 0, score: sdRecipe.ratings?.score ?? 0)
        
        self.init(
            id: sdRecipe.id,
            name: sdRecipe.name,
            description: sdRecipe.desc,
            country: sdRecipe.country,
            thumbnailURL: sdRecipe.thumbnailURL,
            originalVideoURL: sdRecipe.originalVideoURL,
            createdAt: sdRecipe.createdAt,
            approvedAt: sdRecipe.approvedAt,
            yields: sdRecipe.yields,
            isFavorite: sdRecipe.isFavorite,
            ratings: ratings
        )
    }
}

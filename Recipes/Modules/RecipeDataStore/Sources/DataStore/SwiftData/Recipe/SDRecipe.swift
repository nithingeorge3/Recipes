//
//  SDRecipe.swift
//  RecipeDataStore
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation
import SwiftData
import RecipeDomain

#warning("add final for needed class, check id: Int?")
@Model
public final class SDRecipe {
    @Attribute(.unique)
    public var id: Int?
    public var name: String
    public var desc: String?
    public var thumbnailURL: String?
    public var originalVideoURL: String?
    public var createdAt: Int?
    public var approvedAt: Int?
    public var yields: String?
    public var isFavorite: Bool
    public var userRatings: UserRatingsDomain?
    
//    // Transient property for business logic (not persisted)
//    @Transient
//    var country: Country {
//        Country(code: countryCode)
//    }

    @Relationship(inverse: \SDUserRatings.recipe)
    public var rating: SDUserRatings?
    
    init(
        id: Int?,
        name: String,
        desc: String? = nil,
        thumbnailURL: String? = nil,
        originalVideoURL: String? = nil,
        createdAt: Int? = nil,
        approvedAt: Int? = nil,
        yields: String? = nil,
        isFavorite: Bool,
        userRatings: UserRatingsDomain? = nil,
        rating: SDUserRatings? = nil
    ) {
        self.id = id
        self.name = name
        self.desc = desc
        self.thumbnailURL = thumbnailURL
        self.originalVideoURL = originalVideoURL
        self.createdAt = createdAt
        self.approvedAt = approvedAt
        self.yields = yields
        self.isFavorite = isFavorite
        self.userRatings = userRatings
        self.rating = rating
    }
}

extension SDRecipe {
    convenience init(from recipe: RecipeDomain) {
        let ratings = SDUserRatings(from: recipe.userRatings)
        
        self.init(
            id: recipe.id,
            name: recipe.name,
            desc: recipe.description,
            thumbnailURL: recipe.thumbnailURL,
            originalVideoURL: recipe.originalVideoURL,
            createdAt: recipe.createdAt,
            approvedAt: recipe.approvedAt,
            yields: recipe.yields,
            isFavorite: recipe.isFavorite,
            userRatings: recipe.userRatings,
            rating: ratings
            )
    }
}

extension RecipeDomain {
    init(from sdRecipe: SDRecipe) {

        let ratings = UserRatingsDomain(id: sdRecipe.userRatings?.id ?? 0, countNegative: sdRecipe.userRatings?.countNegative, countPositive: sdRecipe.userRatings?.countPositive, score: sdRecipe.userRatings?.score)
        
#warning("remove optional for id")
        self.init(
            id: sdRecipe.id ?? 0,
            name: sdRecipe.name,
            description: sdRecipe.desc,
            thumbnailURL: sdRecipe.thumbnailURL,
            originalVideoURL: sdRecipe.originalVideoURL,
            createdAt: sdRecipe.createdAt,
            approvedAt: sdRecipe.approvedAt,
            yields: sdRecipe.yields,
            userRatings: ratings
        )
    }
}

//
//  Recipe.swift
//  Recipes
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation
import RecipeDomain

struct Recipe: Identifiable, Hashable {
    let id: Int?
    public var name: String
//    public var country: Country?
    let description: String?
    let thumbnailURL: String?
    let originalVideoURL: String?
    let createdAt, approvedAt: Int?
    let yields: String?
    var isFavorite: Bool = false
    let userRatings: UserRatings?

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id
    }
    
    init(id: Int, name: String, description: String? = nil, thumbnailURL: String? = nil, originalVideoURL: String? = nil, createdAt: Int? = nil, approvedAt: Int? = nil, yields: String? = nil, isFavorite: Bool = false, userRatings: UserRatings? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.thumbnailURL = thumbnailURL
        self.originalVideoURL = originalVideoURL
        self.createdAt = createdAt
        self.approvedAt = approvedAt
        self.yields = yields
        self.isFavorite = isFavorite
        self.userRatings = userRatings
    }
}

extension Recipe {
    init(from recipeDomain: RecipeDomain?) {
        let userRatings = UserRatings(from: recipeDomain?.userRatings)
        
        self.id = recipeDomain?.id
        self.name = recipeDomain?.name ?? "Unknown"
        self.description = recipeDomain?.description
        self.thumbnailURL = recipeDomain?.thumbnailURL
        self.originalVideoURL = recipeDomain?.originalVideoURL
        self.createdAt = recipeDomain?.createdAt
        self.approvedAt = recipeDomain?.approvedAt
        self.yields = recipeDomain?.yields
        self.isFavorite = recipeDomain?.isFavorite ?? false
        self.userRatings = userRatings
    }
}

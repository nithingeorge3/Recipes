//
//  RecipeDTO.swift
//  RecipeNetworking
//
//  Created by Nitin George on 01/03/2024.
//

import Foundation
import RecipeDomain

extension RecipeDomain {
    init(from dto: RecipeDTO) {
        let country = Country(from: dto.country ?? .unknown)
        let ratings = UserRatingsDomain(id: dto.id, countNegative: dto.ratings?.countNegative ?? 0, countPositive: dto.ratings?.countPositive ?? 0, score: dto.ratings?.score ?? 0)
        
        self.init(
            id: dto.id,
            name: dto.name,
            description: dto.description,
            country: country,
            thumbnailURL: dto.thumbnailURL,
            originalVideoURL: dto.originalVideoURL,
            createdAt: dto.createdAt,
            approvedAt: dto.approvedAt,
            yields: dto.yields,
            ratings: ratings
        )
    }
}

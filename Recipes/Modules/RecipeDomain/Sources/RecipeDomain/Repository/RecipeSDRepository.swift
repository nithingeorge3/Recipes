//
//  RecipeSDRepository.swift
//  RecipeDomain
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation
import SwiftData

public protocol PaginationRepositoryType: Sendable {
    func fetchRecipePagination(_ pagination: PaginationDomain) async throws -> PaginationDomain
    func updateRecipePagination(_ pagination: PaginationDomain) async throws
}

public protocol RecipeSDRepositoryType: Sendable {
    func fetchRecipes() async throws -> [RecipeDomain]
    func saveRecipes(_ recipes: [RecipeDomain]) async throws
    func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool
}

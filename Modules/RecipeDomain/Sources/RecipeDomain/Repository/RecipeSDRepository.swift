//
//  RecipeSDRepository.swift
//  RecipeDomain
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation
import SwiftData

public protocol PaginationSDRepositoryType: Sendable {
    func fetchPagination(_ entityType: EntityType) async throws -> PaginationDomain
    func updatePagination(_ pagination: PaginationDomain) async throws
}

public protocol RecipeSDRepositoryType: Sendable {
    func fetchRecipesCount() async throws -> Int
    func fetchRecipe(for recipeID: Int) async throws -> RecipeDomain
    func fetchRecipes(startIndex: Int, pageSize: Int) async throws -> [RecipeDomain]
    func saveRecipes(_ recipes: [RecipeDomain]) async throws -> (inserted: [RecipeDomain], updated: [RecipeDomain])
    func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool
}

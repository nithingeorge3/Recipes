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
    func fetchFavoritesRecipesCount() async throws -> Int
    func fetchRecipe(for recipeID: Int) async throws -> RecipeModel
    func fetchRecipes(startIndex: Int, pageSize: Int) async throws -> [RecipeModel]
    func fetchFavorites(startIndex: Int, pageSize: Int) async throws -> [RecipeModel]
    func saveRecipes(_ recipes: [RecipeModel]) async throws -> (inserted: [RecipeModel], updated: [RecipeModel])
    func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool
}

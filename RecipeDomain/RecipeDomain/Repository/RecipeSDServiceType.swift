//
//  RecipeSDRepository.swift
//  RecipeDomain
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation
import SwiftData

public protocol RecipeSDServiceType: Sendable {
    func fetchRecipesCount() async throws -> Int
    func fetchFavoritesRecipesCount() async throws -> Int
    func fetchRecipe(for recipeID: Int) async throws -> RecipeModel
    func fetchRecipes(startIndex: Int, pageSize: Int) async throws -> [RecipeModel]
    func fetchFavorites(startIndex: Int, pageSize: Int) async throws -> [RecipeModel]
    func saveRecipes(_ recipes: [RecipeModel]) async throws -> (inserted: [RecipeModel], updated: [RecipeModel])
    func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool
    func searchRecipes(query: String, startIndex: Int, pageSize: Int) async throws -> [RecipeModel]
}

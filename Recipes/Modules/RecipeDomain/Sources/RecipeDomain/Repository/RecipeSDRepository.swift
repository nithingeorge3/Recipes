//
//  RecipeSDRepository.swift
//  RecipeDomain
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation

public protocol RecipeSDRepositoryType: Sendable {
    func fetchRecipes() async throws -> [RecipeDomain]
    func saveRecipes(_ recipes: [RecipeDomain]) async throws
    func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool
}

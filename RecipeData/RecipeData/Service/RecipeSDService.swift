//
//  RecipeRepository.swift
//  RecipeData
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation
import RecipeDomain
import SwiftData

public final class RecipeSDService: RecipeSDServiceType {
    private let repository: RecipeSDRepositoryType
    
    init(repository: RecipeSDRepositoryType) {
        self.repository = repository
    }
    
    public func fetchRecipesCount() async throws -> Int {
        try await repository.fetchRecipesCount()
    }
    
    public func fetchFavoritesRecipesCount() async throws -> Int {
        try await repository.fetchFavoritesRecipesCount()
    }
    
    public func fetchRecipe(for recipeID: Int) async throws -> RecipeModel {
        try await repository.fetchRecipe(for: recipeID)
    }
    
    public func fetchRecipes(startIndex: Int = 0, pageSize: Int = 40) async throws -> [RecipeModel] {
        try await repository.fetchRecipes(startIndex: startIndex, pageSize: pageSize)
    }
    
    public func fetchFavorites(startIndex: Int = 0, pageSize: Int = 40) async throws -> [RecipeModel] {
        try await repository.fetchFavorites(startIndex: startIndex, pageSize: pageSize)
    }
    
    public func saveRecipes(_ recipes: [RecipeModel]) async throws -> (inserted: [RecipeModel], updated: [RecipeModel]) {
        try await repository.saveRecipes(recipes)
    }
    
    public func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool {
        try await repository.updateFavouriteRecipe(recipeID)
    }
}

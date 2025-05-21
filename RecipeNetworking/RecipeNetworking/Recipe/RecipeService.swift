//
//  RecipeService.swift
//  RecipeNetworking
//
//  Created by Nitin George on 01/03/2024.
//

import Combine
import Foundation
import RecipeDomain

final class RecipeService: RecipeServiceProvider, @unchecked Sendable {
    private let recipeRepository: RecipeRepositoryType
    
    private let favoritesEventService: FavoritesEventServiceType
    
    public var favoriteDidChange: AnyPublisher<Int, Never> {
        favoritesEventService.favoriteDidChange
            .eraseToAnyPublisher()
    }
    
    init(recipeRepository: RecipeRepositoryType, favoritesEventService: FavoritesEventServiceType) {
        self.recipeRepository = recipeRepository
        self.favoritesEventService = favoritesEventService
    }

    func fetchRecipes(endPoint: EndPoint) async throws(NetworkError) -> (inserted: [RecipeModel], updated: [RecipeModel]) {
        do {
            return try await recipeRepository.fetchRecipes(endPoint: endPoint)
            //add business logic
        } catch {
            throw NetworkError.failedToDecode
        }
    }
}

//search
extension RecipeService {
    func searchRecipes(query: String, startIndex: Int, pageSize: Int) async throws -> [RecipeModel] {
        try await recipeRepository.searchRecipes(query: query, startIndex: startIndex, pageSize: pageSize)
    }
}

//SwiftData
extension RecipeService {
    func fetchRecipesCount() async throws -> Int {
        try await recipeRepository.fetchRecipesCount()
    }
    
    func fetchFavoritesRecipesCount() async throws -> Int {
        try await recipeRepository.fetchFavoritesRecipesCount()
    }
    
    func fetchRecipe(for recipeID: Int) async throws -> RecipeModel {
        try await recipeRepository.fetchRecipe(for: recipeID)
    }
    
    func fetchRecipes(startIndex: Int = 0, pageSize: Int = 40) async throws -> [RecipeModel] {
        try await recipeRepository.fetchRecipes(startIndex: startIndex, pageSize: pageSize)
    }
    
    func fetchFavorites(startIndex: Int = 0, pageSize: Int = 40) async throws -> [RecipeModel] {
        try await recipeRepository.fetchFavorites(startIndex: startIndex, pageSize: pageSize)
    }
    
    func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool {
        let isUpdated = try await recipeRepository.updateFavouriteRecipe(recipeID)
        favoritesEventService.favoriteDidChange.send(recipeID) 
        return isUpdated
    }
    
    func fetchPagination(_ entityType: EntityType) async throws -> PaginationDomain {
        return try await recipeRepository.fetchPagination(entityType)
    }
}

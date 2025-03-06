//
//  RecipeServiceImp.swift
//  RecipeNetworking
//
//  Created by Nitin George on 01/03/2024.
//

import Foundation
import RecipeDomain

final class RecipeServiceImp: RecipeServiceProvider {
    private let recipeRepository: RecipeRepositoryType
    private let (favoritesDidChangeStream, favoritesDidChangeContinuation) = AsyncStream.makeStream(of: Int.self)
            
    init(recipeRepository: RecipeRepositoryType) {
        self.recipeRepository = recipeRepository
    }

    func fetchRecipes(endPoint: EndPoint) async throws(NetworkError) -> [RecipeDomain] {
        do {
            return try await recipeRepository.fetchRecipes(endPoint: endPoint)
            //add business logic
        } catch {
            throw NetworkError.failedToDecode
        }
    }
}

//SwiftData
extension RecipeServiceImp {        
    var favoritesDidChange: AsyncStream<Int> { favoritesDidChangeStream }
    
    func fetchRecipes(page: Int = 0, pageSize: Int = 40) async throws -> [RecipeDomain] {
        try await recipeRepository.fetchRecipes(page: page, pageSize: pageSize)
    }
    
    func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool {
        let isUpdated = try await recipeRepository.updateFavouriteRecipe(recipeID)
        favoritesDidChangeContinuation.yield(recipeID)
        return isUpdated
    }
    
    func fetchRecipePagination(_ entityType: EntityType) async throws -> PaginationDomain {
        return try await recipeRepository.fetchRecipePagination(entityType)
    }
}

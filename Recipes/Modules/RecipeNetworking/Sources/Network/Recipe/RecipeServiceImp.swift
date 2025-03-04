//
//  RecipeServiceImp.swift
//  RecipeNetworking
//
//  Created by Nitin George on 01/03/2024.
//

import Foundation
import RecipeDomain

final class RecipeServiceImp: RecipeServiceType {
    private let recipeRepository: RecipeRepositoryType
    private let (favoritesDidChangeStream, favoritesDidChangeContinuation) = AsyncStream.makeStream(of: Int.self)
        
    var favoritesDidChange: AsyncStream<Int> { favoritesDidChangeStream }
    
    init(recipeRepository: RecipeRepositoryType) {
        self.recipeRepository = recipeRepository
    }

    //ToDo: eliminate the need for runtime type checks/casting. use throws (NewsNetworkError)in all place
    func fetchRecipes(endPoint: EndPoint) async throws(NetworkError) -> [RecipeDomain] {
        do {
            return try await recipeRepository.getRecipes(endPoint: endPoint)
            //add business logic
        } catch {
            throw NetworkError.failedToDecode
        }
    }
}

//SwiftData
extension RecipeServiceImp {
    func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool {
        let isUpdated = try await recipeRepository.updateFavouriteRecipe(recipeID)
        favoritesDidChangeContinuation.yield(recipeID)
        return isUpdated
    }
    
    func fetchRecipePagination(_ type: EntityType) async throws -> PaginationDomain {
        let pagination = PaginationDomain(entityType: .recipe)
        return try await recipeRepository.fetchRecipePagination(pagination)
    }
}

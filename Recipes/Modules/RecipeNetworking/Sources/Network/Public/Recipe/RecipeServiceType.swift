//
//  RecipeServiceType.swift
//  RecipeNetworking
//
//  Created by Nitin George on 01/03/2024.
//

import Foundation
import RecipeDomain

public protocol RecipeKeyServiceType {
    @discardableResult
    func deleteRecipeAPIkey() -> Bool
}

public protocol RecipeServiceType: Sendable {
    var favoritesDidChange: AsyncStream<Int> { get }
    
    func fetchRecipes(endPoint: EndPoint) async throws -> [RecipeDomain]
    func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool
    
    func fetchRecipePagination(_ type: EntityType) async throws -> PaginationDomain
}

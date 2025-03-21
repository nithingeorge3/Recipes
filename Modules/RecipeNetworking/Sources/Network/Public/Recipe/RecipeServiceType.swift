//
//  RecipeServiceType.swift
//  RecipeNetworking
//
//  Created by Nitin George on 01/03/2024.
//

import Foundation
import RecipeDomain
import Combine

public protocol RecipeKeyServiceType {
    @discardableResult
    func deleteRecipeAPIkey() -> Bool
}

public typealias RecipeServiceProvider = RecipeServiceType & RecipeSDServiceType

public protocol RecipeServiceType: Sendable {
    func fetchRecipes(endPoint: EndPoint) async throws -> (inserted: [RecipeDomain], updated: [RecipeDomain])
}

public protocol RecipeSDServiceType: Sendable {
    var favoritesDidChange: AsyncStream<Int> { get }
    func fetchRecipe(for recipeID: Int) async throws -> RecipeDomain
    func fetchRecipesCount() async throws -> Int
    func fetchRecipes(startIndex: Int, pageSize: Int) async throws -> [RecipeDomain]
    func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool
    func fetchPagination(_ type: EntityType) async throws -> PaginationDomain
}

//just added for showing combine
public protocol RecipeListServiceType {
    func fetchRecipes(endPoint: EndPoint) -> Future<[RecipeDomain], Error>
}

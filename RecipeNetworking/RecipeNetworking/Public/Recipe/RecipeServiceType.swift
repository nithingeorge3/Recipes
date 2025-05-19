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

public typealias RecipeServiceProvider = RecipeServiceType & RecipeLocalServiceType

//protocol specific for data from server
public protocol RecipeServiceType: Sendable {
    func fetchRecipes(endPoint: EndPoint) async throws -> (inserted: [RecipeModel], updated: [RecipeModel])
}

//protocol specific for data from DB
public protocol RecipeLocalServiceType: Sendable {
    var  favoritesDidChange: AsyncStream<Int> { get }
    func fetchRecipe(for recipeID: Int) async throws -> RecipeModel
    func fetchRecipesCount() async throws -> Int
    func fetchFavoritesRecipesCount() async throws -> Int
    func fetchRecipes(startIndex: Int, pageSize: Int) async throws -> [RecipeModel]
    func fetchFavorites(startIndex: Int, pageSize: Int) async throws -> [RecipeModel]
    func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool
    func fetchPagination(_ type: EntityType) async throws -> PaginationDomain
}

//just added for showing combine
public protocol RecipeListServiceType {
    func fetchRecipes(endPoint: EndPoint) -> Future<[RecipeModel], Error>
}

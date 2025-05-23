//
//  RecipeRepository.swift
//  RecipeNetworking
//
//  Created by Nitin George on 01/03/2024.
//

import Combine
import Foundation
import RecipeDomain
import RecipeCore

//we can split protocol. backend and SwiftData fetch
public protocol RecipeRepositoryType: Sendable {
    func fetchRecipes(endPoint: EndPoint) async throws -> (inserted: [RecipeModel], updated: [RecipeModel])
    func fetchRecipesCount() async throws -> Int
    func fetchFavoritesRecipesCount() async throws -> Int
    func fetchRecipe(for recipeID: Int) async throws -> RecipeModel
    func fetchRecipes(startIndex: Int, pageSize: Int) async throws -> [RecipeModel]
    func fetchFavorites(startIndex: Int, pageSize: Int) async throws -> [RecipeModel]
    func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool
    func fetchPagination(_ entityType: EntityType) async throws -> PaginationDomain
    func searchRecipes(query: String, startIndex: Int, pageSize: Int) async throws -> [RecipeModel]
}

final class RecipeRepository: RecipeRepositoryType {
    private let parser: ServiceParserType
    private let requestBuilder: RequestBuilderType
    private let apiKeyProvider: APIKeyProviderType
    private let recipeSDService: RecipeSDServiceType
    private let paginationSDService: PaginationSDServiceType
    private let configuration: AppConfigurableRecipeType
    
    init(
        parser: ServiceParserType,
        requestBuilder: RequestBuilderType,
        apiKeyProvider: APIKeyProviderType,
        recipeSDService: RecipeSDServiceType,
        paginationSDService: PaginationSDServiceType,
        configuration: AppConfigurableRecipeType
    ) {
        self.parser = parser
        self.requestBuilder = requestBuilder
        self.apiKeyProvider = apiKeyProvider
        self.recipeSDService = recipeSDService
        self.paginationSDService = paginationSDService
        self.configuration = configuration
    }
    
    func fetchRecipes(endPoint: EndPoint) async throws -> (inserted: [RecipeModel], updated: [RecipeModel]) {
        do {
            let apiKey = try await apiKeyProvider.getRecipeAPIKey()
            
            let url = try endPoint.url(baseURL: configuration.recipeBaseURL, endPoint: configuration.recipeEndPoint)
            
            let (data, response) = try await URLSession.shared.data(for: requestBuilder.buildRequest(url: url, apiKey: apiKey))
            
            let dtos = try await parser.parse(
                data: data,
                response: response,
                type: RecipeResponseDTO.self
            )
            
            let recipeDomains = dtos.results.map { RecipeModel(from: $0) }

            //Reach the last page or no data available
            if recipeDomains.count == 0 {
                return ([], [])
            }
            
            let result = try await recipeSDService.saveRecipes(recipeDomains)
            
            var pagination = try await paginationSDService.fetchPagination(.recipe)
            pagination.totalCount = dtos.count
            pagination.currentPage += 1
            pagination.lastUpdated = Date()
            
            //updating Pagination
            try await paginationSDService.updatePagination(pagination)
                        
            return result
        } catch {
            throw NetworkError.noNetworkAndNoCache(context: error)
        }
    }
}

extension RecipeRepository {
    func fetchRecipesCount() async throws -> Int {
        try await recipeSDService.fetchRecipesCount()
    }
    
    func fetchFavoritesRecipesCount() async throws -> Int {
        try await recipeSDService.fetchFavoritesRecipesCount()
    }
    
    func fetchRecipe(for recipeID: Int) async throws -> RecipeModel {
        try await recipeSDService.fetchRecipe(for: recipeID)
    }
    
    func fetchRecipes(startIndex: Int, pageSize: Int) async throws -> [RecipeModel] {
        try await recipeSDService.fetchRecipes(startIndex: startIndex, pageSize: pageSize)
    }
    
    func fetchFavorites(startIndex: Int, pageSize: Int) async throws -> [RecipeModel] {
        try await recipeSDService.fetchFavorites(startIndex: startIndex, pageSize: pageSize)
    }
    
    func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool {
        try await recipeSDService.updateFavouriteRecipe(recipeID)
    }
    
    func fetchPagination(_ entityType: EntityType) async throws -> PaginationDomain {
        try await paginationSDService.fetchPagination(entityType)
    }
}

//search
extension RecipeRepository {
    func searchRecipes(query: String, startIndex: Int, pageSize: Int) async throws -> [RecipeModel] {
        try await recipeSDService.searchRecipes(query: query, startIndex: startIndex, pageSize: pageSize)
    }
}

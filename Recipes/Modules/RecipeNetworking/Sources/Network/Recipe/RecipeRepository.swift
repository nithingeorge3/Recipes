//
//  RecipeRepository.swift
//  RecipeNetworking
//
//  Created by Nitin George on 01/03/2024.
//

import Foundation
import RecipeDomain

public protocol RecipeRepositoryType: Sendable {
    func getRecipes(endPoint: EndPoint) async throws -> [RecipeDomain]
    func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool
}

final class RecipeRepository: RecipeRepositoryType {
    private let parser: ServiceParserType
    private let requestBuilder: RequestBuilderType
    private let apiKeyProvider: APIKeyProviderType
    private let recipeSDRepo: RecipeSDRepositoryType
    
    init(
        parser: ServiceParserType,
        requestBuilder: RequestBuilderType,
        apiKeyProvider: APIKeyProviderType,
        recipeSDRepo: RecipeSDRepositoryType
    ) {
        self.parser = parser
        self.requestBuilder = requestBuilder
        self.apiKeyProvider = apiKeyProvider
        self.recipeSDRepo = recipeSDRepo
    }
    
    func getRecipes(endPoint: EndPoint) async throws -> [RecipeDomain] {
        do {
            let apiKey = try await apiKeyProvider.getRecipeAPIKey()
            
            let (data, response) = try await URLSession.shared.data(for: requestBuilder.buildRequest(url: endPoint.url(), apiKey: apiKey))
            
            let dtos = try await parser.parse(
                data: data,
                response: response,
                type: RecipeResponseDTO.self
            )
            print(dtos.count)
            print(dtos.results.count)
            
            let domains = dtos.results.map { RecipeDomain(from: $0) }

            print(domains.count)
            //Reach the page end or no data
            if domains.count == 0 {
                return domains
            }
            
            try await recipeSDRepo.saveRecipes(domains)
            
#warning("fetch batch recipes")
            let savedRecipes = try await recipeSDRepo.fetchRecipes()
            print("***Saved recipe Count: \(savedRecipes.count)")
            
            return domains//savedRecipes
        } catch {
            let savedRecipes = try await recipeSDRepo.fetchRecipes()
            print("***Saved recipes Count: \(savedRecipes.count)")
            
            throw NetworkError.noNetworkAndNoCache(context: error)
            
            guard !savedRecipes.isEmpty else {
                throw NetworkError.noNetworkAndNoCache(context: error)
            }
            return savedRecipes
        }
    }
}

extension RecipeRepository {
    func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool {
        try await recipeSDRepo.updateFavouriteRecipe(recipeID)
    }
}

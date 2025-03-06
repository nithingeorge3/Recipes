//
//  RecipeServiceFactory.swift
//  RecipeNetworking
//
//  Created by Nitin George on 01/03/2024.
//

import Foundation
import RecipeDomain

public protocol RecipeKeyServiceFactoryType {
    static func makeRecipeKeyService() -> RecipeKeyServiceType
}

public protocol RecipeServiceFactoryType {
    static func makeRecipeService(recipeSDRepo: RecipeSDRepositoryType, paginationSDRepo: PaginationRepositoryType) -> RecipeServiceProvider
}

public final class RecipeServiceFactory: RecipeServiceFactoryType, RecipeKeyServiceFactoryType, @unchecked Sendable {
    private static let apiKeyProvider: APIKeyProviderType = APIKeyProvider(keyChainManager: KeyChainManager.shared)
    private static let serviceParser: ServiceParserType = ServiceParser()
    private static let requestBuilder: RequestBuilderType = RequestBuilder()
    
    public static func makeRecipeService(recipeSDRepo: RecipeSDRepositoryType, paginationSDRepo: PaginationRepositoryType) -> RecipeServiceProvider {
        let recipeRepository: RecipeRepositoryType = RecipeRepository(
            parser: serviceParser,
            requestBuilder: requestBuilder,
            apiKeyProvider: apiKeyProvider,
            recipeSDRepo: recipeSDRepo,
            paginationSDRepo: paginationSDRepo
        )
        return RecipeServiceImp(recipeRepository: recipeRepository)
    }
    
    public static func makeRecipeKeyService() -> any RecipeKeyServiceType {
        let recipeKeyRepo: RecipeKeyRepositoryType = RecipeKeyRepository(keyChainManager: KeyChainManager.shared)
        return RecipeKeyService(recipeKeyRepo: recipeKeyRepo)
    }
}

//
//  RecipeServiceFactory.swift
//  RecipeNetworking
//
//  Created by Nitin George on 01/03/2024.
//

import Foundation
import RecipeDomain
import RecipeCore

public protocol RecipeKeyServiceFactoryType {
    static func makeRecipeKeyService() -> RecipeKeyServiceType
}

public protocol RecipeServiceFactoryType {
    static func makeRecipeService(recipeSDService: RecipeSDServiceType, paginationSDService: PaginationSDServiceType, favoritesEventService: FavoritesEventServiceType, configuration: AppConfigurableRecipeType) -> RecipeServiceProvider
}

public final class RecipeServiceFactory: RecipeServiceFactoryType, RecipeKeyServiceFactoryType, @unchecked Sendable {
    private static let apiKeyProvider: APIKeyProviderType = APIKeyProvider(keyChainManager: KeyChainManager.shared)
    private static let serviceParser: ServiceParserType = ServiceParser()
    private static let requestBuilder: RequestBuilderType = RequestBuilder()
    
    public static func makeRecipeService(
        recipeSDService: RecipeSDServiceType,
        paginationSDService: PaginationSDServiceType,
        favoritesEventService: FavoritesEventServiceType,
        configuration: AppConfigurableRecipeType
    ) -> RecipeServiceProvider {
        let recipeRepository: RecipeRepositoryType = RecipeRepository(
            parser: serviceParser,
            requestBuilder: requestBuilder,
            apiKeyProvider: apiKeyProvider,
            recipeSDService: recipeSDService,
            paginationSDService: paginationSDService,
            configuration: configuration
        )
        return RecipeService(recipeRepository: recipeRepository, favoritesEventService: favoritesEventService)
    }
    
    public static func makeRecipeKeyService() -> any RecipeKeyServiceType {
        let recipeKeyRepo: RecipeKeyRepositoryType = RecipeKeyRepository(keyChainManager: KeyChainManager.shared)
        return RecipeKeyService(recipeKeyRepo: recipeKeyRepo)
    }
}

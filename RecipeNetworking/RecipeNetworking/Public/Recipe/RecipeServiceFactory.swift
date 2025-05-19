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
    static func makeRecipeService(recipeSDService: RecipeSDServiceType, paginationSDService: PaginationSDServiceType) -> RecipeServiceProvider
}

public final class RecipeServiceFactory: RecipeServiceFactoryType, RecipeKeyServiceFactoryType, @unchecked Sendable {
    private static let apiKeyProvider: APIKeyProviderType = APIKeyProvider(keyChainManager: KeyChainManager.shared)
    private static let serviceParser: ServiceParserType = ServiceParser()
    private static let requestBuilder: RequestBuilderType = RequestBuilder()
    
    public static func makeRecipeService(recipeSDService: RecipeSDServiceType, paginationSDService: PaginationSDServiceType) -> RecipeServiceProvider {
        let recipeRepository: RecipeRepositoryType = RecipeRepository(
            parser: serviceParser,
            requestBuilder: requestBuilder,
            apiKeyProvider: apiKeyProvider,
            recipeSDService: recipeSDService,
            paginationSDService: paginationSDService
        )
        return RecipeService(recipeRepository: recipeRepository)
    }
    
    public static func makeRecipeKeyService() -> any RecipeKeyServiceType {
        let recipeKeyRepo: RecipeKeyRepositoryType = RecipeKeyRepository(keyChainManager: KeyChainManager.shared)
        return RecipeKeyService(recipeKeyRepo: recipeKeyRepo)
    }
}

//just added for showing combine. In production I will only use Async/await or combine based on the decision
public protocol RecipeServiceListFactoryType {
    static func makeRecipeListService() -> RecipeListServiceType
}

public final class RecipeListServiceFactory: RecipeServiceListFactoryType {
    //Need to inject same as above function RecipeServiceFactory.makeRecipeService
    private static let serviceParser: ServiceParserType = ServiceParser()
    private static let requestBuilder: RequestBuilderType = RequestBuilder()
    
    public static func makeRecipeListService() -> RecipeListServiceType {
        let recipeRepository: RecipeListRepositoryType = RecipeListRepository(
            parser: serviceParser,
            requestBuilder: requestBuilder
        )
        return RecipeListServiceImp(recipeRepository: recipeRepository)
    }
}

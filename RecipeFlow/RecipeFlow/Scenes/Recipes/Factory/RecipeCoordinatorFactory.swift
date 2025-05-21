//
//  RecipeListCoordinatorFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Foundation
import SwiftData
import RecipeData
import RecipeUI
import RecipeNetworking
import RecipeCore

public protocol RecipeListCoordinatorFactoryType {
    @MainActor func makeRecipeListCoordinator(container: ModelContainer, tabBarVisibility: TabBarVisibility,  favoritesEventService: FavoritesEventServiceType, configuration: AppConfigurableRecipeType) async -> RecipeListCoordinator
}

public final class RecipeListCoordinatorFactory: RecipeListCoordinatorFactoryType {
    public init() { }
    
    public func makeRecipeListCoordinator(
        container: ModelContainer,
        tabBarVisibility: TabBarVisibility,
        favoritesEventService: FavoritesEventServiceType,
        configuration: AppConfigurableRecipeType
    ) async -> RecipeListCoordinator {
        
        let tabItem = TabItem(title: "Recipe", icon: "house.fill", badgeCount: 0, color: .black)
        
        let modelFactory = RecipesViewModelFactory()
        let viewFactory = RecipesViewFactory()
        
        let paginationSDService = PaginationSDServiceFactory().makePaginationSDService(container: container)
        let recipeSDService = RecipeSDServiceFactory().makeRecipeSDService(container: container)
        
        
        let recipeService = RecipeServiceFactory.makeRecipeService(
            recipeSDService: recipeSDService,
            paginationSDService: paginationSDService,
            favoritesEventService: favoritesEventService,
            configuration: configuration
        )

    
        return await RecipeListCoordinator(
            tabItem: tabItem,
            tabBarVisibility: tabBarVisibility,
            viewFactory: viewFactory,
            modelFactory: modelFactory,
            service: recipeService
//            paginationSDService: paginationSDService,
//            recipeSDService: recipeSDService,
//            favoritesEventService: favoritesEventService
        )
    }
}

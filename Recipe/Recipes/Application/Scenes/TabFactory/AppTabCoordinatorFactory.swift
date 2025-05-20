//
//  AppTabViewFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftData
import RecipeUI
import RecipeFlow
import RecipeNetworking

@MainActor
protocol AppTabCoordinatorFactoryType {
    func makeAppTabCoordinator(container: ModelContainer, tabBarVisibility: TabBarVisibility) async -> AppTabCoordinator
}

final class AppTabCoordinatorFactory: AppTabCoordinatorFactoryType {
    func makeAppTabCoordinator(container: ModelContainer, tabBarVisibility: TabBarVisibility) async -> AppTabCoordinator {
        
        let favoritesEventService = FavoritesEventService()
        
        let recipeCoordinatorFactory = RecipeListCoordinatorFactory()
        let recipeCoordinator = await recipeCoordinatorFactory.makeRecipeListCoordinator(
            container: container,
            tabBarVisibility: tabBarVisibility,
            favoritesEventService: favoritesEventService
        )
        
        let favRecipeCoordinatorFactory = RecipeFavouritesCoordinatorFactory()
        let favRecipeCoordinator = await favRecipeCoordinatorFactory.make(
            container: container,
            tabBarVisibility: tabBarVisibility,
            favoritesEventService: favoritesEventService
        )
        
        let menuCoordinatorFactory = MenuCoordinatorFactory()
        let menuCoordinator = menuCoordinatorFactory.makeMenuCoordinator()
        
        let viewFactory = AppTabViewFactory(coordinators: [recipeCoordinator,
                                                           favRecipeCoordinator,
                                                           menuCoordinator], tabBarVisibility: tabBarVisibility)
        
        return AppTabCoordinator(appTabViewFactory: viewFactory)
    }
}

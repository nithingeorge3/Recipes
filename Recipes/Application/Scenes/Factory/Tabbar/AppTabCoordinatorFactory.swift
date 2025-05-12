//
//  AppTabViewFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftData
import RecipeUI
import RecipeFlow

@MainActor
protocol AppTabCoordinatorFactoryType {
    func makeAppTabCoordinator(container: ModelContainer, tabBarVisibility: TabBarVisibility) async -> AppTabCoordinator
}

final class AppTabCoordinatorFactory: AppTabCoordinatorFactoryType {
    func makeAppTabCoordinator(container: ModelContainer, tabBarVisibility: TabBarVisibility) async -> AppTabCoordinator {
        let recipeCoordinatorFactory = RecipeListCoordinatorFactory()
        let recipeCoordinator = await recipeCoordinatorFactory.makeRecipeListCoordinator(container: container, tabBarVisibility: tabBarVisibility)
        
        let menuViewModelFactory = MenuViewModelFactory()
        let menuViewFactory = MenuViewFactory(menuViewModelFactory: menuViewModelFactory)
        let menuCoordinatorFactory = MenuCoordinatorFactory(menuViewFactory: menuViewFactory)
        let menuCoordinator = menuCoordinatorFactory.makeMenuCoordinator()
        
        let viewFactory = AppTabViewFactory(coordinators: [recipeCoordinator,
                                                           menuCoordinator], tabBarVisibility: tabBarVisibility)
        
        return AppTabCoordinator(appTabViewFactory: viewFactory)
    }
}

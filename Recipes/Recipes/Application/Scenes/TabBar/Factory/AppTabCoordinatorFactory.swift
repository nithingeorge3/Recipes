//
//  AppTabViewFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftData

@MainActor
protocol AppTabCoordinatorFactoryType {
    func makeAppTabCoordinator(container: ModelContainer) async -> AppTabCoordinator
}

final class AppTabCoordinatorFactory: AppTabCoordinatorFactoryType {
    func makeAppTabCoordinator(container: ModelContainer) async -> AppTabCoordinator {
        let recipeCoordinatorFactory = RecipeListCoordinatorFactory()
        let recipeCoordinator = await recipeCoordinatorFactory.makeRecipeListCoordinator(container: container)
        
        let menuViewModelFactory = MenuViewModelFactory()
        let menuViewFactory = MenuViewFactory(menuViewModelFactory: menuViewModelFactory)
        let menuCoordinatorFactory = MenuCoordinatorFactory(menuViewFactory: menuViewFactory)
        let menuCoordinator = menuCoordinatorFactory.makeMenuCoordinator()
        
        let viewFactory = AppTabViewFactory(coordinators: [recipeCoordinator,
                                                           menuCoordinator])
        
        return AppTabCoordinator(appTabViewFactory: viewFactory)
    }
}

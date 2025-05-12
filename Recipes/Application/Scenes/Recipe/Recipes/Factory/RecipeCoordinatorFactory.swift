//
//  RecipeListCoordinatorFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Foundation
import SwiftData
import RecipeDataStore
import RecipeUI

protocol RecipeListCoordinatorFactoryType {
    @MainActor func makeRecipeListCoordinator(container: ModelContainer, tabBarVisibility: TabBarVisibility) async -> RecipeListCoordinator
}

final class RecipeListCoordinatorFactory: RecipeListCoordinatorFactoryType {
    func makeRecipeListCoordinator(container: ModelContainer, tabBarVisibility: TabBarVisibility) async -> RecipeListCoordinator {
        let tabItem = TabItem(title: "Recipe", icon: "house.fill", badgeCount: 0, color: .black)
        let modelFactory = RecipesViewModelFactory()
        let viewFactory = RecipesViewFactory()
        
        let paginationSDRepo = PaginationSDRepository(container: container)
        let recipeSDRepo = RecipeSDRepository(container: container)
        
        return await RecipeListCoordinator(
            tabItem: tabItem,
            tabBarVisibility: tabBarVisibility,
            viewFactory: viewFactory,
            modelFactory: modelFactory,
            paginationSDRepo: paginationSDRepo,
            recipeSDRepo: recipeSDRepo
        )
    }
}

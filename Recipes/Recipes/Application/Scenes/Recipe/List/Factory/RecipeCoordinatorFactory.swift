//
//  RecipeListCoordinatorFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Foundation
import SwiftData
import RecipeDataStore
import RecipeDataStore

protocol RecipeListCoordinatorFactoryType {
    @MainActor func makeRecipeListCoordinator(container: ModelContainer) async -> RecipeListCoordinator
}

final class RecipeListCoordinatorFactory: RecipeListCoordinatorFactoryType {
    func makeRecipeListCoordinator(container: ModelContainer) async -> RecipeListCoordinator {
        let tabItem = TabItem(title: "Recipe", icon: "house.fill", badgeCount: 0, color: .black)
        let modelFactory = RecipeListViewModelFactory()
        let viewFactory = RecipeListViewFactory()
        
        let paginationSDRepo = PaginationRepository(container: container)
        let recipeSDRepo = RecipeSDRepository(container: container)
        
        return await RecipeListCoordinator(
            tabItem: tabItem,
            viewFactory: viewFactory,
            modelFactory: modelFactory,
            paginationSDRepo: paginationSDRepo,
            recipeSDRepo: recipeSDRepo
        )
    }
}

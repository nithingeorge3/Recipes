//
//  RecipeListCoordinatorFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Foundation
import SwiftData
import RecipeDataStore

protocol RecipeListCoordinatorFactoryType {
    @MainActor func makeRecipeListCoordinator(context: ModelContext) async -> RecipeListCoordinator
}

final class RecipeListCoordinatorFactory: RecipeListCoordinatorFactoryType {
    func makeRecipeListCoordinator(context: ModelContext) async -> RecipeListCoordinator {
        let tabItem = TabItem(title: "Recipe", icon: "house.fill", badgeCount: 0, color: .black)
        let modelFactory = RecipeListViewModelFactory()
        let viewFactory = RecipeListViewFactory()
        
        let recipeSDRepo = RecipeSDRepository(context: context)
        return await RecipeListCoordinator(
            tabItem: tabItem,
            viewFactory: viewFactory,
            modelFactory: modelFactory,
            recipeSDRepo: recipeSDRepo
        )
    }
}

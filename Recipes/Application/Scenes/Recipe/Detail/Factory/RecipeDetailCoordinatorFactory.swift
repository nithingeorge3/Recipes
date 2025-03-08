//
//  RecipeDetailCoordinatorFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Foundation
import RecipeNetworking

protocol RecipeDetailCoordinatorFactoryType {
    @MainActor func makeRecipeDetailCoordinator(recipeID: Recipe.ID, service: RecipeSDServiceType) -> RecipeDetailCoordinator
}

final class RecipeDetailCoordinatorFactory: RecipeDetailCoordinatorFactoryType {
    func makeRecipeDetailCoordinator(recipeID: Recipe.ID, service: RecipeSDServiceType) -> RecipeDetailCoordinator {
        let viewModelFactory: RecipeDetailViewModelFactoryType = RecipeDetailViewModelFactory()
        let viewFactory: RecipeDetailViewFactoryType = RecipeDetailViewFactory()
        return RecipeDetailCoordinator(
            viewModelFactory: viewModelFactory,
            viewFactory: viewFactory,
            recipeID: recipeID,
            service: service
        )
    }
}

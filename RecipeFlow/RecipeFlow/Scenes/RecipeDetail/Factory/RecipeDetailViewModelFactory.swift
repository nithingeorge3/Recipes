//
//  RecipeDetailViewModelFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import RecipeNetworking
import RecipeCore
import RecipeDomain

protocol RecipeDetailViewModelFactoryType {
    @MainActor func makeRecipeDetailViewModel(recipeID: Recipe.ID, service: RecipeLocalServiceType) -> RecipeDetailViewModel
}

final class RecipeDetailViewModelFactory: RecipeDetailViewModelFactoryType {
    @MainActor func makeRecipeDetailViewModel(recipeID: Recipe.ID, service: RecipeLocalServiceType) -> RecipeDetailViewModel {
        RecipeDetailViewModel(recipeID: recipeID, service: service)
    }
}

//
//  RecipeDetailViewModelFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import RecipeNetworking

protocol RecipeDetailViewModelFactoryType {
    @MainActor func makeRecipeDetailViewModel(recipe: Recipe, service: RecipeServiceType) -> RecipeDetailViewModel
}

final class RecipeDetailViewModelFactory: RecipeDetailViewModelFactoryType {
    @MainActor func makeRecipeDetailViewModel(recipe: Recipe, service: RecipeServiceType) -> RecipeDetailViewModel {
        RecipeDetailViewModel(recipe: recipe, service: service)
    }
}

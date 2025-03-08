//
//  RecipeListViewModelFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import RecipeNetworking

protocol RecipesViewModelFactoryType {
    @MainActor func makeRecipeListViewModel(service: RecipeServiceProvider, paginationHandler: PaginationHandlerType) async -> RecipeListViewModel
}

final class RecipesViewModelFactory: RecipesViewModelFactoryType {
    func makeRecipeListViewModel(service: RecipeServiceProvider, paginationHandler: PaginationHandlerType) async -> RecipeListViewModel {
        RecipeListViewModel(service: service, paginationHandler: paginationHandler)
    }
}

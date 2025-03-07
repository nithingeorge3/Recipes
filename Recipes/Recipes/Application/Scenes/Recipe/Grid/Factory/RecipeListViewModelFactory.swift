//
//  RecipeListViewModelFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import RecipeNetworking

protocol RecipeListViewModelFactoryType {
    @MainActor func makeRecipeListViewModel(service: RecipeServiceProvider, paginationHandler: PaginationHandlerType) async -> RecipeListViewModel
}

final class RecipeListViewModelFactory: RecipeListViewModelFactoryType {
    func makeRecipeListViewModel(service: RecipeServiceProvider, paginationHandler: PaginationHandlerType) async -> RecipeListViewModel {
        RecipeListViewModel(service: service, paginationHandler: paginationHandler)
    }
}

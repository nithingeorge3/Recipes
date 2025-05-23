//
//  RecipeListViewModelFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import RecipeNetworking
import RecipeData

protocol RecipesViewModelFactoryType {
    @MainActor func makeRecipeListViewModel(service: RecipeServiceProvider, remotePagination: RemotePaginationHandlerType, localPagination: LocalPaginationHandlerType, searchPagination: LocalPaginationHandlerType) async -> RecipeListViewModel
}

final class RecipesViewModelFactory: RecipesViewModelFactoryType {
    func makeRecipeListViewModel(
        service: RecipeServiceProvider,
        remotePagination: RemotePaginationHandlerType,
        localPagination: LocalPaginationHandlerType,
        searchPagination: LocalPaginationHandlerType
    ) async -> RecipeListViewModel {
        RecipeListViewModel(
            service: service,
            remotePagination: remotePagination,
            localPagination: localPagination,
            searchPagination: searchPagination
        )
    }
}

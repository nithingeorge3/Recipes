//
//  RecipeListViewModelFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import RecipeNetworking
import RecipeDataStore

protocol RecipesViewModelFactoryType {
    @MainActor func makeRecipeListViewModel(service: RecipeServiceProvider, remotePagination: RemotePaginationHandlerType, localPagination: LocalPaginationHandlerType, favoritesPagination: LocalPaginationHandlerType) async -> RecipeListViewModel
}

final class RecipesViewModelFactory: RecipesViewModelFactoryType {
    func makeRecipeListViewModel(
        service: RecipeServiceProvider,
        remotePagination: RemotePaginationHandlerType,
        localPagination: LocalPaginationHandlerType,
        favoritesPagination: LocalPaginationHandlerType
    ) async -> RecipeListViewModel {
        RecipeListViewModel(
            service: service,
            remotePagination: remotePagination,
            localPagination: localPagination,
            favoritesPagination: favoritesPagination
        )
    }
}

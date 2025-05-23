//
//  RecipeFavouritesViewModelFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import RecipeNetworking
import RecipeData

protocol RecipeFavouritesViewModelFactoryType {
    @MainActor func make(service: RecipeServiceProvider, favoritesPagination: LocalPaginationHandlerType) async -> RecipeFavouritesViewModel
}

final class RecipeFavouritesViewModelFactory: RecipeFavouritesViewModelFactoryType {
    func make(
        service: RecipeServiceProvider,
        favoritesPagination: LocalPaginationHandlerType
    ) async -> RecipeFavouritesViewModel {
        RecipeFavouritesViewModel(
            service: service,
            favoritesPagination: favoritesPagination
        )
    }
}

//
//  RecipesFavouritesViewFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Foundation

protocol RecipeFavouritesViewFactoryType {
    @MainActor func make<ViewModel: RecipeFavouritesViewModelType>(
        viewModel: ViewModel
    ) -> RecipeFavouritesView<ViewModel>
    
}

final class RecipeFavouritesViewFactory: RecipeFavouritesViewFactoryType {
    @MainActor func make<ViewModel: RecipeFavouritesViewModelType>(
        viewModel: ViewModel
    ) -> RecipeFavouritesView<ViewModel> {
        RecipeFavouritesView(viewModel: viewModel)
    }
}

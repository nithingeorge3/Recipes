//
//  RecipeListViewFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Foundation

protocol RecipesViewFactoryType {
    @MainActor func makeRecipesGridView<ViewModel: RecipesListViewModelType>(
        viewModel: ViewModel
    ) -> RecipesListView<ViewModel>
}

final class RecipesViewFactory: RecipesViewFactoryType {
    @MainActor func makeRecipesGridView<ViewModel: RecipesListViewModelType>(
        viewModel: ViewModel
    ) -> RecipesListView<ViewModel> {
        RecipesListView(viewModel: viewModel)
    }
}

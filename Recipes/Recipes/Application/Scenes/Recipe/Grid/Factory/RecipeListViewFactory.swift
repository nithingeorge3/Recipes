//
//  RecipeListViewFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Foundation

protocol RecipeListViewFactoryType {
    @MainActor func makeRecipeListView<ViewModel: RecipesListViewModelType>(
        viewModel: ViewModel
    ) -> RecipesListView<ViewModel>
}

final class RecipeListViewFactory: RecipeListViewFactoryType {
    @MainActor func makeRecipeListView<ViewModel: RecipesListViewModelType>(
        viewModel: ViewModel
    ) -> RecipesListView<ViewModel> {
        RecipesListView(viewModel: viewModel)
    }
}

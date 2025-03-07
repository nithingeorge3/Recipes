//
//  RecipeListViewFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Foundation

protocol RecipeListViewFactoryType {
    @MainActor func makeRecipeListView<ViewModel: RecipeListViewModelType>(
        viewModel: ViewModel
    ) -> RecipeListView<ViewModel>
}

final class RecipeListViewFactory: RecipeListViewFactoryType {
    @MainActor func makeRecipeListView<ViewModel: RecipeListViewModelType>(
        viewModel: ViewModel
    ) -> RecipeListView<ViewModel> {
        RecipeListView(viewModel: viewModel)
    }
}

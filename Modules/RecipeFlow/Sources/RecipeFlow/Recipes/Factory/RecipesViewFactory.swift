//
//  RecipeListViewFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Foundation

public protocol RecipesViewFactoryType {
    @MainActor func makeRecipesGridView<ViewModel: RecipesListViewModelType>(
        viewModel: ViewModel
    ) -> RecipesListView<ViewModel>
    
    @MainActor func makeRecipesListView<ViewModel: RecipesViewModelType>(
        viewModel: ViewModel
    ) -> RecipesView<ViewModel>
}

public final class RecipesViewFactory: RecipesViewFactoryType {
    public init() {}
    
    @MainActor public func makeRecipesGridView<ViewModel: RecipesListViewModelType>(
        viewModel: ViewModel
    ) -> RecipesListView<ViewModel> {
        RecipesListView(viewModel: viewModel)
    }
    
    @MainActor public func makeRecipesListView<ViewModel: RecipesViewModelType>(
        viewModel: ViewModel
    ) -> RecipesView<ViewModel> {
        RecipesView(viewModel: viewModel)
    }
}

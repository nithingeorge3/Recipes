//
//  RecipeDetailViewFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

protocol RecipeDetailViewFactoryType {
    @MainActor func makeRecipeDetailView<ViewModel: RecipeDetailViewModelType>(
        viewModel: ViewModel
    ) -> RecipeDetailView<ViewModel>
}

final class RecipeDetailViewFactory: RecipeDetailViewFactoryType {
    @MainActor func makeRecipeDetailView<ViewModel: RecipeDetailViewModelType>(
        viewModel: ViewModel
    ) -> RecipeDetailView<ViewModel> {
        RecipeDetailView(viewModel: viewModel)
    }
}

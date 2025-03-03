//
//  RecipeDetailViewFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

protocol RecipeDetailViewFactoryType {
    func makeRecipeDetailView(viewModel: RecipeDetailViewModel) -> RecipeDetailView
}

final class RecipeDetailViewFactory: RecipeDetailViewFactoryType {
    func makeRecipeDetailView(viewModel: RecipeDetailViewModel) -> RecipeDetailView {
        RecipeDetailView(viewModel: viewModel)
    }
}

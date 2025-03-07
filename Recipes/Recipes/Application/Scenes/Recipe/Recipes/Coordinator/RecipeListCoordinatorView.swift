//
//  RecipeListCoordinatorView.swift
//  Recipe
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI

struct RecipeListCoordinatorView: View {
    @ObservedObject var coordinator: RecipeListCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
                coordinator.viewFactory.makeRecipesGridView(viewModel: coordinator.viewModel)
                .navigationDestination(for: RecipeListAction.self) { action in
                    switch action {
                    case .userSelectedRecipe(let recipe):
                        coordinator.navigateToRecipeDetail(for: recipe)
                    default: EmptyView()
                    }
                }
            }
            .navigationBarTitle("Recipe")
        }
}

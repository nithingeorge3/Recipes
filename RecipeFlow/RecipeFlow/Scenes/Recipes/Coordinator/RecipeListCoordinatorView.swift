//
//  RecipeListCoordinatorView.swift
//  Recipe
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI
import RecipeUI

struct RecipeListCoordinatorView: View {
    @ObservedObject var coordinator: RecipeListCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
                coordinator.viewFactory.makeRecipesGridView(viewModel: coordinator.viewModel)
                    .environmentObject(coordinator.tabBarVisibility)
                .navigationDestination(for: RecipeAction.self) { action in
                    switch action {
                    case .selectRecipe(let recipeID):
                        coordinator.navigateToRecipeDetail(for: recipeID)
                    default: EmptyView()
                    }
                }
            }
            .navigationBarTitle("Recipe")
        }
}

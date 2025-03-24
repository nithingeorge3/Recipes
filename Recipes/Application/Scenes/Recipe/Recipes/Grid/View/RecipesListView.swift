//
//  RecipesListView.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI
import Combine

struct RecipesListView<ViewModel: RecipesListViewModelType>: View {
    @Bindable var viewModel: ViewModel
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    
    var body: some View {
        VStack {
            switch viewModel.state {
                case .loading:
                    ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)
                case.failed(let error):
                    ErrorView(error: error) {
                        viewModel.send(.refresh)
                    }
                case .success:
                if viewModel.isEmpty {
                    EmptyStateView(message: "No recipes found. Please try again later.")
                } else {
                    RecipesGridView(favorites: viewModel.favoriteRecipes, others: viewModel.otherRecipes, hasMoreData: viewModel.remotePagination.hasMoreData) { recipe in
                        viewModel.send(.selectRecipe(recipe.id))
                    } onReachBottom: {
                        viewModel.send(.loadMore)
                    }
                }
            }
        }.onAppear {
            viewModel.send(.refresh)
            tabBarVisibility.isHidden = false
        }
        .withCustomNavigationTitle(title: "Recipes")
    }
}

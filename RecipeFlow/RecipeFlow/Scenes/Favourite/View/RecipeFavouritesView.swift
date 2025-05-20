//
//  RecipesFavouritesView.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI
import Combine
import RecipeUI

struct RecipeFavouritesView<ViewModel: RecipeFavouritesViewModelType>: View {
    var viewModel: ViewModel
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    
    var body: some View {
        content
            .withCustomNavigationTitle(title: "Favourites")
//            .navigationAccessibility(title: "Recipes")
            .onAppear(perform: handleAppear)
            .accessibilityElement(children: .contain)
    }
    
    private var content: some View {
        Group {
            switch viewModel.state {
            case .loading:
                loadingView
            case .failed(let error):
                errorView(error: error)
            case .empty(let message):
                EmptyStateView(message: message)
                    .accessibilityLabel("Empty recipe favourite list")
            case .success:
                successContent
            }
        }
    }
    
    private var loadingView: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .scaleEffect(1.5)
            .accessibilityLabel("Loading favourites")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(error: Error) -> some View {
        ErrorView(error: error) {
            Task {
                await viewModel.send(.refresh)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAction(named: "Retry") {
            Task {
                await viewModel.send(.refresh)
            }
        }
    }
    
    @ViewBuilder
    private var successContent: some View {
        RecipesGridView(
            recipes: viewModel.recipes,
            hasMoreData: viewModel.favouritePagination.hasMoreData
        ) { recipe in
            Task {
                await viewModel.send(.selectRecipe(recipe.id))
            }
        } onReachBottom: {
            Task {
                await viewModel.send(.loadMore)
            }
        }
        .accessibilityLabel("Favourite recipes collection")
    }
    
    private func handleAppear() {
        Task {
//            await viewModel.loadInitialData()
            await viewModel.send(.refresh)
        }
        
        tabBarVisibility.isHidden = false
        
        UIAccessibility.post(
            notification: .screenChanged,
            argument: viewModel.isEmpty ? "No favourite found" : "favourites loaded"
        )
    }
}

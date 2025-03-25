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
        content
            .navigationAccessibility(title: "Recipes")
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
            case .success:
                successContent
            }
        }
    }
    
    private var loadingView: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .scaleEffect(1.5)
            .accessibilityLabel("Loading recipes")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(error: Error) -> some View {
        ErrorView(error: error) {
            viewModel.send(.refresh)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAction(named: "Retry") {
            viewModel.send(.refresh)
        }
    }
    
    @ViewBuilder
    private var successContent: some View {
        if viewModel.isEmpty {
            EmptyStateView(message: "No recipes found. Please try again later.")
                .accessibilityLabel("Empty recipe list")
        } else {
            RecipesGridView(
                favorites: viewModel.favoriteRecipes,
                others: viewModel.otherRecipes,
                hasMoreData: viewModel.remotePagination.hasMoreData
            ) { recipe in
                viewModel.send(.selectRecipe(recipe.id))
            } onReachBottom: {
                viewModel.send(.loadMore)
            }
            .accessibilityLabel("Recipes collection")
        }
    }
    
    private func handleAppear() {
        viewModel.send(.refresh)
        tabBarVisibility.isHidden = false
        
        UIAccessibility.post(
            notification: .screenChanged,
            argument: viewModel.isEmpty ? "No recipes found" : "Recipes loaded"
        )
    }
}

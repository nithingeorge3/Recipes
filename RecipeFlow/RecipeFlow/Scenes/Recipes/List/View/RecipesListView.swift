//
//  RecipesListView.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI
import Combine
import RecipeUI

struct RecipesListView<ViewModel: RecipesListViewModelType>: View {
    @Bindable var viewModel: ViewModel
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    
    @State private var showSearch = false
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        content
            .searchable(
                text: $viewModel.searchQuery,
                isPresented: $showSearch,
                placement: .toolbar
            )
            .withCustomNavigationTitle(title: viewModel.navTitle)
            .navigationAccessibility(title: viewModel.navTitle)
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
                    .accessibilityLabel("Empty recipe list")
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
            hasMoreData: viewModel.remotePagination.hasMoreData
        ) { recipe in
            Task {
                await viewModel.send(.selectRecipe(recipe.id))
            }
        } onReachBottom: {
            Task {
                await viewModel.send(.loadMore)
            }
        }
        .accessibilityLabel("Recipes collection")
    }
    
    private func handleAppear() {
        Task {
            await viewModel.loadInitialData()
            await viewModel.send(.refresh)
        }
        
        tabBarVisibility.isHidden = false
        
        UIAccessibility.post(
            notification: .screenChanged,
            argument: viewModel.isEmpty ? "No recipes found" : "Recipes loaded"
        )
    }
}

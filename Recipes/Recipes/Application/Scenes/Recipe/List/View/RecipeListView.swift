//
//  RecipeListView.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI
import RecipeNetworking
import Combine

struct RecipeListView<ViewModel: RecipeListViewModelType>: View {
    @Bindable var viewModel: ViewModel
   
    private var isEmpty: Bool {
        viewModel.recipes.isEmpty
    }
    
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
                if isEmpty {
                    EmptyStateView(message: "No recipes found. Please try again later.")
                } else {
                    RecipesGridView(favorites: viewModel.favoriteRecipes, others: viewModel.otherRecipes, hasMoreData: viewModel.paginationState.hasMoreData) { recipe in
                        viewModel.send(.userSelectedRecipe(recipe))
                    } onReachBottom: {
                        viewModel.send(.loadNextPage) // not added the functionality
                    }
                }
            }
        }.onAppear {
            viewModel.send(.refresh)
        }
        .withCustomNavigationTitle(title: "Recipes")
    }
}

// MARK: - Previews
#Preview("Loading State") {
    RecipeListView(viewModel: PreviewRecipeListViewModel(state: .loading))
}

#Preview("Success State with Recipes") {
    RecipeListView(viewModel: PreviewRecipeListViewModel(state: .success))
}

#Preview("Empty State") {
    let vm = PreviewRecipeListViewModel(state: .success)
    vm.recipes = []
    return RecipeListView(viewModel: vm)
}

#Preview("Error State") {
    RecipeListView(viewModel: PreviewRecipeListViewModel(
        state: .failed(error: NSError(domain: "Error", code: -1))
    ))
}

private class PreviewRecipeListViewModel: RecipeListViewModelType {
    var recipes: [Recipe] = [
        Recipe(id: 1, name: "Kerala Chicken", isFavorite: true),
        Recipe(id: 2, name: "Kerala Dosha", isFavorite: false),
        Recipe(id: 3, name: "Kerala CB", isFavorite: true)
    ]
    
    var favoriteRecipes: [Recipe] { recipes.filter { $0.isFavorite } }
    var otherRecipes: [Recipe] { recipes.filter { !$0.isFavorite } }
    var paginationState: PaginationStateType = PreviewPaginationState()
    var recipeListActionSubject = PassthroughSubject<RecipeListAction, Never>()
    var state: ResultState
    
    init(state: ResultState) {
        self.state = state
    }
    
    func send(_ action: RecipeListAction) {
    }
}

private class PreviewPaginationState: PaginationStateType {
    var currentPage: Int = 1
    var isFetching: Bool = false
    var hasMoreData: Bool = true
    var shouldFetch: Bool { hasMoreData && !isFetching }
    
    func beginFetch() {
        isFetching = true
    }
    
    func completeFetch(hasMoreData: Bool) {
        self.hasMoreData = hasMoreData
    }
}

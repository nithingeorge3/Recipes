//
//  RecipesPreviews.swift
//  Recipes
//
//  Created by Nitin George on 24/03/2025.
//

import SwiftUI
import Combine
import RecipeUI
import RecipeCore
import RecipeData
import RecipeDomain

#if DEBUG
#Preview("Loading State") {
    RecipesListView(viewModel: PreviewRecipeListViewModel(state: .loading))
        .environmentObject(TabBarVisibility())
}

#Preview("Success State") {
    let vm = PreviewRecipeListViewModel(state: .success)
    return RecipesListView(viewModel: vm)
        .environmentObject(TabBarVisibility())
}

#Preview("Empty State") {
    let vm = PreviewRecipeListViewModel(state: .success)
    vm.recipes = []
    return RecipesListView(viewModel: vm)
        .environmentObject(TabBarVisibility())
}

#Preview("Error State") {
    RecipesListView(viewModel: PreviewRecipeListViewModel(state: .failed(error: RecipeError.fetchFailed("Recipe fetch failure"))))
                                                                            
        .environmentObject(TabBarVisibility())
}

@MainActor @Observable
private class PreviewRecipeListViewModel: RecipesListViewModelType {
    var searchQuery = ""
    
    var isSearching = false
    
    func searchRecipes() async {
        
    }
    
    var navTitle = "Recipes"
    
    var emptyRecipeMessage = "No recipes found. Please try again later."
    var state: ResultState
    var recipes: [Recipe] = []
    var remotePagination: RemotePaginationHandlerType
    var localPagination: LocalPaginationHandlerType
    var searchPagination: LocalPaginationHandlerType
    var recipeActionSubject = PassthroughSubject<RecipeAction, Never>()
    
    var isEmpty: Bool {
        recipes.isEmpty && !remotePagination.isLoading && !localPagination.isLoading
    }
    
    init(state: ResultState) {
        self.state = state
        self.remotePagination = MockRemotePaginationHandler()
        self.localPagination = MockLocalPaginationHandler()
        self.searchPagination = MockSearchPaginationHandler()
        
        configureForState(state)
    }
    
    private func configureForState(_ state: ResultState) {
        switch state {
        case .success:
            setupSuccessState()
        case .loading:
            setupLoadingState()
        case .failed(let error):
            setupErrorState(error: error)
        default: break
        }
    }
    
    private func setupSuccessState() {
        recipes = (1...10).map { index in
            Recipe(
                id: index,
                name: "Recipe \(index)",
                country: .us,
                isFavorite: false,
                ratings: UserRatings(id: index)
            )
        }
        
        remotePagination.totalItems = 50
        localPagination.totalItems = 25
    }
    
    private func setupLoadingState() {
        recipes = (1...5).map { index in Recipe(id: index, name: "Salad \(index)", ratings: UserRatings(id: index)) }
        remotePagination.isLoading = true
        localPagination.isLoading = true
    }
    
    private func setupErrorState(error: Error) {
        recipes = []
        remotePagination.isLoading = false
        localPagination.isLoading = false
        state = .failed(error: RecipeError.fetchFailed("Recipe fetch failure"))
    }
    
    func send(_ action: RecipeAction) async {
        switch action {
        case .refresh:
            Task {
                if !recipes.isEmpty {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    configureForState(.success)
                }
            }
        case .loadMore: break
        case .selectRecipe(let id):
            recipeActionSubject.send(.selectRecipe(id))
        }
    }
    
    func loadInitialData() {
    }
}
#endif

//
//  RecipesPreviews.swift
//  Recipes
//
//  Created by Nitin George on 24/03/2025.
//

import SwiftUI
import Combine

// MARK: - Previews
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
    vm.favoriteRecipes = []
    vm.otherRecipes = []
    return RecipesListView(viewModel: vm)
        .environmentObject(TabBarVisibility())
}

#Preview("Error State") {
    RecipesListView(viewModel: PreviewRecipeListViewModel(state: .failed(error: NSError(domain: "Preview", code: 00))))
        .environmentObject(TabBarVisibility())
}

@MainActor @Observable
private class PreviewRecipeListViewModel: RecipesListViewModelType {
    var state: ResultState
    var favoriteRecipes: [Recipe] = []
    var otherRecipes: [Recipe] = []
    var remotePagination: RemotePaginationHandlerType
    var localPagination: LocalPaginationHandlerType
    var recipeListActionSubject = PassthroughSubject<RecipeListAction, Never>()
    
    var isEmpty: Bool {
        favoriteRecipes.isEmpty && otherRecipes.isEmpty && !remotePagination.isLoading && !localPagination.isLoading
    }
    
    init(state: ResultState) {
        self.state = state
        self.remotePagination = PreviewRemotePaginationHandler()
        self.localPagination = PreviewLocalPaginationHandler()
        
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
        }
    }
    
    private func setupSuccessState() {
        otherRecipes = (1...10).map { index in
            Recipe(
                id: index,
                name: "Recipe \(index)",
                country: .us,
                isFavorite: false,
                ratings: UserRatings(id: index)
            )
        }
        
        favoriteRecipes = [
            Recipe(
                id: 99,
                name: "Favorite Recipe",
                country: .ind,
                isFavorite: true,
                ratings: UserRatings(id: 99)
            )
        ]
        
        remotePagination.totalItems = 50
        localPagination.totalItems = 25
    }
    
    private func setupLoadingState() {
        otherRecipes = (1...5).map { index in Recipe(id: index, name: "Salad \(index)", ratings: UserRatings(id: index)) }
        remotePagination.isLoading = true
        localPagination.isLoading = true
    }
    
    private func setupErrorState(error: Error) {
        otherRecipes = []
        favoriteRecipes = []
        remotePagination.isLoading = false
        localPagination.isLoading = false
        state = .failed(error: error)
    }
    
    func send(_ action: RecipeListAction) async {
        switch action {
        case .refresh:
            Task {
                if !favoriteRecipes.isEmpty && !otherRecipes.isEmpty {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    configureForState(.success)
                }
            }
        case .loadMore: break
        case .selectRecipe(let id):
            recipeListActionSubject.send(.selectRecipe(id))
        }
    }
    
    func loadInitialData() {
    }
}

private class PreviewRemotePaginationHandler: RemotePaginationHandlerType {
    var currentPage: Int = 1
    var totalItems: Int = 50
    var hasMoreData: Bool = true
    var isLoading: Bool = false
    var lastUpdated: Date = Date()
    
    func reset() {
        currentPage = 1
        totalItems = 50
        isLoading = false
    }
        
    func updateFromDomain(_ pagination: Pagination) {
        totalItems = pagination.totalCount
        currentPage = pagination.currentPage
        lastUpdated = pagination.lastUpdated
    }
}

private class PreviewLocalPaginationHandler: LocalPaginationHandlerType {
    var currentOffset: Int = 0
    var pageSize: Int = 10
    var totalItems: Int = 25
    var hasMoreData: Bool { currentOffset + pageSize < totalItems }
    var isLoading: Bool = false
    var lastUpdated: Date = Date()
    
    func reset() {
        currentOffset = 0
        isLoading = false
    }
    
    func incrementOffset() {
        currentOffset += pageSize
    }
    
    func updateTotalItems(_ newValue: Int) {
        totalItems = newValue
    }
}
#endif

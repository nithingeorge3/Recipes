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
                    RecipesGridView(favorites: viewModel.favoriteRecipes, others: viewModel.otherRecipes, hasMoreData: viewModel.paginationHandler.hasMoreData) { recipe in
                        viewModel.send(.selectRecipe(recipe.id))
                    } onReachBottom: {
                        viewModel.send(.loadMore)
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
#if DEBUG
#Preview("Loading State") {
    RecipesListView(viewModel: PreviewRecipeListViewModel(state: .loading))
}

#Preview("Success State with Recipes") {
    RecipesListView(viewModel: PreviewRecipeListViewModel(state: .success))
}

#Preview("Empty State") {
    let vm = PreviewRecipeListViewModel(state: .success)
    vm.recipes = []
    return RecipesListView(viewModel: vm)
}

#Preview("Error State") {
    RecipesListView(viewModel: PreviewRecipeListViewModel(
        state: .failed(error: NSError(domain: "Error", code: -1))
    ))
}

private class PreviewRecipeListViewModel: RecipesListViewModelType {    
    var recipes: [Recipe] = [
        Recipe(id: 1, name: "Kerala Chicken", thumbnailURL: "https://img.buzzfeed.com/thumbnailer-prod-us-east-1/45b4efeb5d2c4d29970344ae165615ab/FixedFBFinal.jpg" ,isFavorite: true),
        Recipe(id: 2, name: "Kerala Dosha", thumbnailURL: "https://img.buzzfeed.com/thumbnailer-prod-us-east-1/video-api/assets/314886.jpg", isFavorite: false),
        Recipe(id: 3, name: "Kerala CB", thumbnailURL: "https://s3.amazonaws.com/video-api-prod/assets/654d0916588d46c5835b7a5f547a090e/BestPastaFB.jpg", isFavorite: true)
    ]
    var pagination: Pagination? = Pagination(entityType: .recipe)
    var favoriteRecipes: [Recipe] { recipes.filter { $0.isFavorite } }
    var otherRecipes: [Recipe] { recipes.filter { !$0.isFavorite } }
    var paginationHandler: PaginationHandlerType = PreviewPaginationHandler()
    var recipeListActionSubject = PassthroughSubject<RecipeListAction, Never>()
    var state: ResultState
    
    init(state: ResultState) {
        self.state = state
    }
    
    func send(_ action: RecipeListAction) {
    }
}

private class PreviewPaginationHandler: PaginationHandlerType {
    var currentPage: Int = 1
    var totalItems: Int = 10
    var hasMoreData: Bool = true
    var isLoading: Bool = false
    var lastUpdated: Date = Date()
    
    func reset() {
        currentPage = 0
        totalItems = 0
        isLoading = false
        lastUpdated = Date()
    }
    
    func validateLoadMore(index: Int) -> Bool {
        false
    }
    
    func updateFromDomain(_ pagination: Pagination) {
        totalItems = pagination.totalCount
        currentPage = pagination.currentPage
        lastUpdated = pagination.lastUpdated
    }
}
#endif

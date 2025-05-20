//
//  RecipesFavouriteViewModel.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Combine
import Foundation
import Observation
import RecipeNetworking
import RecipeDomain
import RecipeCore
import RecipeData

@MainActor
protocol RecipeFavouritesViewModelType: AnyObject, Observable {
    var recipes: [Recipe] { get }
    var isEmpty: Bool { get }
    var favouritePagination: LocalPaginationHandlerType { get }
    var recipeActionSubject: PassthroughSubject<RecipeAction, Never> { get  set }
    var state: ResultState { get }
    
    func send(_ action: RecipeAction) async
    func loadInitialData() async
}

@Observable
class RecipeFavouritesViewModel: RecipeFavouritesViewModelType {
    var state: ResultState = .loading
    let service: RecipeServiceProvider
    var recipeActionSubject = PassthroughSubject<RecipeAction, Never>()
        
    var favouritePagination: LocalPaginationHandlerType
    
    var recipes: [Recipe] = []
       
    var isEmpty: Bool {
        recipes.isEmpty &&
        !favouritePagination.isLoading
    }
    
    init(
        service: RecipeServiceProvider,
        favoritesPagination: LocalPaginationHandlerType
    ) {
        self.service = service
        self.favouritePagination = favoritesPagination

        listeningFavoritesChanges()
    }
    
    func send(_ action: RecipeAction) async {
        switch action {
        case .refresh, .loadMore:
            await fetchRecipes()
        case .selectRecipe( let recipeID):
            recipeActionSubject.send(RecipeAction.selectRecipe(recipeID))
        }
    }
    
    func loadInitialData() async {
        do {
            let count = try await service.fetchFavoritesRecipesCount()
            favouritePagination.updateTotalItems(count)
        } catch {
            print("error while updating pagination \(error)")
        }
    }
}

private extension RecipeFavouritesViewModel {
    private func fetchRecipes() async {
        let hasMoreFaves = favouritePagination.hasMoreData
        
        if favouritePagination.hasMoreData {
            do {
                try await fetchLocalFavoritesRecipes()
            } catch {
                print("error. handle later")
            }
        }
    }

    
    private func fetchLocalFavoritesRecipes() async throws {
        guard favouritePagination.hasMoreData else { return }
        favouritePagination.isLoading = true
        defer { favouritePagination.isLoading = false }
        
        let recipeDomains = try await service.fetchFavorites(
                startIndex: 0,
                pageSize: favouritePagination.pageSize
            )
        
        let favRecipes = recipeDomains.map { Recipe(from: $0) }
        
        recipes = favRecipes
        if !recipes.isEmpty {
            favouritePagination.isLoading = false
            favouritePagination.incrementOffset()
        }
        state = .success
    }
    
    private func listeningFavoritesChanges() {

    }
    
//    private func updateRecipeFavoritesStatus(recipeID: Int) {
//        if let index = otherRecipes.firstIndex(where: { $0.id == recipeID }) {
//            var movedRecipe = otherRecipes.remove(at: index)
//            movedRecipe.isFavorite = true
//            favoriteRecipes.append(movedRecipe)
//        } else if let index = favoriteRecipes.firstIndex(where: { $0.id == recipeID }) {
//            var movedRecipe = favoriteRecipes.remove(at: index)
//            movedRecipe.isFavorite = false
//            otherRecipes.append(movedRecipe)
//        }
//    }
}

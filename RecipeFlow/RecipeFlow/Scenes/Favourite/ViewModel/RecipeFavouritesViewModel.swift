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
    private var emptyFavoritesMessage = "You haven’t added any favourite recipes."
    
    private var cancellables = Set<AnyCancellable>()
    
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
        recipes.removeAll()
        listeningFavoritesChanges()
    }
    
    func send(_ action: RecipeAction) async {
        switch action {
        case .refresh, .loadMore:
            await loadInitialData()
            await fetchLocalRecipes()
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
    private func fetchLocalRecipes() async {
        guard favouritePagination.hasMoreData else {
            if recipes.isEmpty {
                favouritePagination.reset()
                state = .empty(message: emptyFavoritesMessage)
            }
            return
        }
        
        do {
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
        } catch {
            print("error. handle later")
        }
    }
    
    private func listeningFavoritesChanges() {
        service.favoriteDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] recipeID in
                self?.updateRecipeFavoriteStatus(recipeID: recipeID)
            }
            .store(in: &cancellables)
    }
    
    private func updateRecipeFavoriteStatus(recipeID: Int) {
        if let index = recipes.firstIndex(where: { $0.id == recipeID }) {
            recipes.remove(at: index)
            favouritePagination.decrementTotalItems()
        }
    }
}

//
//  RecipeListViewModel.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Combine
import Foundation
import Observation
import RecipeNetworking
import RecipeDomain

@MainActor
protocol RecipeListViewModelType: AnyObject, Observable {
    var recipes: [Recipe] { get }
    var favoriteRecipes: [Recipe] { get }
    var otherRecipes: [Recipe] { get }
    var paginationState: PaginationStateType { get }
    var recipeListActionSubject: PassthroughSubject<RecipeListAction, Never> { get  set }
    var state: ResultState { get }
    
    func send(_ action: RecipeListAction)
}

@Observable
class RecipeListViewModel: RecipeListViewModelType {
    var state: ResultState = .loading
    var recipes: [Recipe] = []
    let service: RecipeServiceType
    var paginationState: PaginationStateType
    var recipeListActionSubject = PassthroughSubject<RecipeListAction, Never>()

    private var maxAllowedRecipesCount: Int
    
    private var updateTask: Task<Void, Never>?
    
    var favoriteRecipes: [Recipe] {
        recipes.filter { $0.isFavorite }
    }
    
    var otherRecipes: [Recipe] {
        recipes.filter { !$0.isFavorite }
    }
    
    init(
        service: RecipeServiceType,
        paginationState: PaginationStateType,
        maxAllowedRecipesCount: Int = 10
    ) {
        self.service = service
        self.paginationState = paginationState
        self.maxAllowedRecipesCount = maxAllowedRecipesCount
        listeningFavoritesChanges()
    }
    
    private func listeningFavoritesChanges() {
        updateTask = Task { [weak self] in
            guard let self = self else { return }
            for await recipeID in self.service.favoritesDidChange {
                self.updateRecipeFavoritesStatus(recipeID: recipeID)
            }
        }
    }
    
    private func updateRecipeFavoritesStatus(recipeID: Int) {
        guard let index = recipes.firstIndex(where: { $0.id == recipeID }) else { return }
        if recipes.count > index - 1 {
            recipes[index].isFavorite.toggle()
        }
    }
    
    func send(_ action: RecipeListAction) {
        switch action {
        case .refresh:
            Task { try await fetchRecipes() }
        case .loadNextPage: break
//            Task { try await loadNextPage() }
        case .userSelectedRecipe( let recipe):
            recipeListActionSubject.send(RecipeListAction.userSelectedRecipe(recipe))
        }
    }
    
    private func fetchRecipes() async throws {
        guard recipes.count == 0 else { return }
        do {            
            let recipeDomains = try await service.fetchRecipes(
                endPoint: .recipes(page: paginationState.currentPage, limit: Constants.recipesFetchLimit)
            )
            
            let newRecipes = recipeDomains.map { Recipe(from: $0) }
            
            updateRecipes(with: newRecipes)
        } catch let error {
            state = .failed(error: error)
        }
    }
    
    private func loadNextPage() async throws {
        //toDo
    }
    
    private func updateRecipes(with fetchedRecipes: [Recipe]) {
        if fetchedRecipes.count > 0 {
            recipes = fetchedRecipes
        }

        state = .success
        
        let isCompleted = recipes.count >= maxAllowedRecipesCount || fetchedRecipes.isEmpty
        paginationState.completeFetch(hasMoreData: !isCompleted)
    }
}

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
    var paginationHandler: PaginationHandlerType { get }
    var recipeListActionSubject: PassthroughSubject<RecipeListAction, Never> { get  set }
    var state: ResultState { get }
    
    func send(_ action: RecipeListAction)
}

@Observable
class RecipeListViewModel: RecipeListViewModelType {
    var state: ResultState = .loading
    var recipes: [Recipe] = []
    let service: RecipeServiceProvider
    var paginationHandler: PaginationHandlerType
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
        service: RecipeServiceProvider,
        paginationHandler: PaginationHandlerType,
        maxAllowedRecipesCount: Int = 10
    ) {
        self.service = service
        self.paginationHandler = paginationHandler
        self.maxAllowedRecipesCount = maxAllowedRecipesCount
        Task { try await fetchRecipePagination() }
        Task { try await fetchLocalRecipes() }
        listeningFavoritesChanges()
    }
    
    func send(_ action: RecipeListAction) {
        switch action {
        case .refresh:
            Task { try await fetchRemoteRecipes() }
        case .loadNextPage:
            guard paginationHandler.hasMoreData else { return }
            Task { try await fetchRemoteRecipes() }
        case .userSelectedRecipe( let recipe):
            recipeListActionSubject.send(RecipeListAction.userSelectedRecipe(recipe))
        }
    }
    
    private func fetchRecipePagination() async throws {
        Task {
            do {
                let paginationDomain = try await service.fetchRecipePagination(.recipe)
                updatePagination(Pagination(from: paginationDomain))
            } catch {
                print("\(error)")
            }
        }
    }
    
    private func fetchLocalRecipes() async throws {
        Task {
            do {
                let recipeDomains = try await service.fetchRecipes(
                        page: 0,
                        pageSize: Constants.Recipe.fetchLimit
                    )
                
                let storedRecipes = recipeDomains.map { Recipe(from: $0) }
                
                if storedRecipes.count > 0 {
                    recipes = storedRecipes
                    state = .success
                }
            } catch {
                state = .failed(error: error)
            }
        }
    }
    
    private func fetchRemoteRecipes() async throws {
        guard !paginationHandler.isLoading else {
            return
        }
        paginationHandler.isLoading = true
        Task {
            do {
                let recipeDomains = try await service.fetchRecipes(
                    endPoint: .recipes(
                        page: paginationHandler.currentPage,
                        limit: Constants.Recipe.fetchLimit
                    )
                )
                let newRecipes = recipeDomains.map { Recipe(from: $0) }
                updateRecipes(with: newRecipes)
                try await fetchRecipePagination()
            } catch {
                if recipes.count == 0 {
                    state = .failed(error: error)
                }
            }
        }
    }
    
    private func updateRecipes(with fetchedRecipes: [Recipe]) {
        if fetchedRecipes.count > 0 {
            recipes.append(contentsOf: fetchedRecipes)
        }
        
        state = .success
    }
    
    private func updatePagination(_ pagination: Pagination) {
        paginationHandler.updateFromDomain(pagination)
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
}

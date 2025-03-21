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
protocol RecipesListViewModelType: AnyObject, Observable {
    var recipes: [Recipe] { get }
    var favoriteRecipes: [Recipe] { get }
    var otherRecipes: [Recipe] { get }
    var remotePagination: RemotePaginationHandlerType { get }
    var localPagination: LocalPaginationHandlerType { get }
    var recipeListActionSubject: PassthroughSubject<RecipeListAction, Never> { get  set }
    var state: ResultState { get }
    
    func send(_ action: RecipeListAction)
}

@Observable
class RecipeListViewModel: RecipesListViewModelType {
    var state: ResultState = .loading
    var recipes: [Recipe] = []
    let service: RecipeServiceProvider
    var remotePagination: RemotePaginationHandlerType
    var localPagination: LocalPaginationHandlerType
    
    var recipeListActionSubject = PassthroughSubject<RecipeListAction, Never>()
    
    private var updateTask: Task<Void, Never>?
    
    var favoriteRecipes: [Recipe] {
        recipes.filter { $0.isFavorite }
    }
    
    var otherRecipes: [Recipe] {
        recipes.filter { !$0.isFavorite }
    }
    
    init(
        service: RecipeServiceProvider,
        remotePagination: RemotePaginationHandlerType,
        localPagination: LocalPaginationHandlerType
    ) {
        self.service = service
        self.remotePagination = remotePagination
        self.localPagination = localPagination
        
        Task { try await updateLocalPagination() }
        Task { try await updateRemotePagination() }
        listeningFavoritesChanges()
    }
    
    func send(_ action: RecipeListAction) {
        switch action {
        case .refresh:
            if localPagination.hasMoreData {
                Task { try await fetchLocalRecipes() }
            } else if remotePagination.hasMoreData {
                Task { try await fetchRemoteRecipes() }
            }
        case .loadMore:
            Task {
                do {
                    if localPagination.hasMoreData {
                        try await fetchLocalRecipes()
                    } else if remotePagination.hasMoreData {
                        try await fetchRemoteRecipes()
                    }
                } catch {
                    print("error: \(error)")
                }
            }
        case .selectRecipe( let recipeID):
            recipeListActionSubject.send(RecipeListAction.selectRecipe(recipeID))
        }
    }
    
    private func updateRemotePagination() async throws {
        Task {
            do {
                let paginationDomain = try await service.fetchPagination(.recipe)
                remotePagination.updateFromDomain(Pagination(from: paginationDomain))
            } catch {
                print("\(error)")
            }
        }
    }
    
    private func updateLocalPagination() async throws {
        let count = try await service.fetchRecipesCount()
        localPagination.updateTotalItems(count)
    }
    
    private func fetchLocalRecipes() async throws {
        Task {
            do {
                let recipeDomains = try await service.fetchRecipes(
                        startIndex: localPagination.currentOffset,
                        pageSize: localPagination.pageSize
                    )
                
                let storedRecipes = recipeDomains.map { Recipe(from: $0) }
                
                if storedRecipes.count > 0 {
                    recipes.append(contentsOf: storedRecipes)
                    
                    localPagination.incrementOffset()
                    state = .success
                }
            } catch {
                state = .failed(error: error)
            }
        }
    }
    
    private func fetchRemoteRecipes() async throws {
        guard !remotePagination.isLoading else {
            return
        }
        
        remotePagination.isLoading = true
        
        Task {
            do {
                let results = try await service.fetchRecipes(
                    endPoint: .recipes(
                        startIndex: remotePagination.currentPage,
                        pageSize: Constants.Recipe.fetchLimit
                    )
                )
                
                updateRemoteRecipes(with: results)
                
                try await updateRemotePagination()
            } catch {
                if recipes.count == 0 {
                    remotePagination.isLoading = false
                    state = .failed(error: error)
                }
            }
        }
    }
    
    private func updateRemoteRecipes(with fetchedRecipes: (inserted: [RecipeDomain], updated: [RecipeDomain])) {
        let newRecipes = fetchedRecipes.inserted.map { Recipe(from: $0) }
        let updatedRecipes = fetchedRecipes.updated.map { Recipe(from: $0) }
        
        recipes.append(contentsOf: newRecipes)
        
        for recipe in updatedRecipes {
            if let index = self.recipes.firstIndex(where: { $0.id == recipe.id }) {
                self.recipes[index] = recipe
            }
        }
        
        remotePagination.isLoading = false
        state = .success
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

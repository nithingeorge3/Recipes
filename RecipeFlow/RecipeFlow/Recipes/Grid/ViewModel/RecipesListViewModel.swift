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
import RecipeCore
import RecipeData

@MainActor
protocol RecipesListViewModelType: AnyObject, Observable {
    var favoriteRecipes: [Recipe] { get }
    var otherRecipes: [Recipe] { get }
    var isEmpty: Bool { get }
    var remotePagination: RemotePaginationHandlerType { get }
    var localPagination: LocalPaginationHandlerType { get }
    var recipeListActionSubject: PassthroughSubject<RecipeListAction, Never> { get  set }
    var state: ResultState { get }
    
    func send(_ action: RecipeListAction) async
    func loadInitialData() async
}

@Observable
class RecipeListViewModel: RecipesListViewModelType {
    var state: ResultState = .loading
    let service: RecipeServiceProvider
    var remotePagination: RemotePaginationHandlerType
    var localPagination: LocalPaginationHandlerType
    var favoritesPagination: LocalPaginationHandlerType
    var recipeListActionSubject = PassthroughSubject<RecipeListAction, Never>()
    
    private var updateTask: Task<Void, Never>?
    
    var favoriteRecipes: [Recipe] = []
   
    var otherRecipes: [Recipe] = []
    
    var isEmpty: Bool {
        otherRecipes.isEmpty &&
        favoriteRecipes.isEmpty &&
        !remotePagination.isLoading &&
        !localPagination.isLoading &&
        !favoritesPagination.isLoading
    }
    
    init(
        service: RecipeServiceProvider,
        remotePagination: RemotePaginationHandlerType,
        localPagination: LocalPaginationHandlerType,
        favoritesPagination: LocalPaginationHandlerType
    ) {
        self.service = service
        self.remotePagination = remotePagination
        self.localPagination = localPagination
        self.favoritesPagination = favoritesPagination

        listeningFavoritesChanges()
    }
    
    func send(_ action: RecipeListAction) async {
        switch action {
        case .refresh, .loadMore:
            await fetchRecipes()
        case .selectRecipe( let recipeID):
            recipeListActionSubject.send(RecipeListAction.selectRecipe(recipeID))
        }
    }
    
    func loadInitialData() async {
        async let updateFavPagination: Void = updateFavoritesPagination()
        async let updateLocalPagination: Void = updateLocalPagination()
        async let updateRemotePagination: Void = updateRemotePagination()
        
        do {
            _ = try await (updateFavPagination, updateLocalPagination, updateRemotePagination)
        } catch {
            print("error while updating pagination \(error)")
        }
    }
}

private extension RecipeListViewModel {
    private func fetchRecipes() async {
        let hasMoreFaves = favoritesPagination.hasMoreData
        let hasMoreLocal = localPagination.hasMoreData
        let hasMoreRemote = remotePagination.hasMoreData
        
        async let favourates: Void? = hasMoreFaves
                                        ? fetchLocalFavoritesRecipes()
                                        : nil
        
        async let localOrRemote: Void? = hasMoreLocal
                                        ? fetchLocalRecipes()
                                        : (hasMoreRemote ? fetchRemoteRecipes() : nil)
        
        do {
            _ = try await (favourates, localOrRemote)
        } catch {
            if otherRecipes.count == 0 {
                state = .failed(error: error)
            }
            print("error fetching recipes: \(error)")
        }
    }
    
    private func updateRemotePagination() async throws {
        let paginationDomain = try await service.fetchPagination(.recipe)
        remotePagination.updateFromDomain(Pagination(from: paginationDomain))
    }
    
    private func updateFavoritesPagination() async throws {
        let count = try await service.fetchFavoritesRecipesCount()
        favoritesPagination.updateTotalItems(count)
    }
    
    private func updateLocalPagination() async throws {
        let count = try await service.fetchRecipesCount()
        localPagination.updateTotalItems(count)
    }
    
    private func fetchLocalRecipes() async throws {
        guard localPagination.hasMoreData else { return }

        localPagination.isLoading = true
        defer { localPagination.isLoading = false }

        let recipeDomains = try await service.fetchRecipes(
                startIndex: localPagination.currentOffset,
                pageSize: localPagination.pageSize
            )

        let storedRecipes = recipeDomains.map { Recipe(from: $0) }

        if storedRecipes.count > 0 {
            otherRecipes.append(contentsOf: storedRecipes)
            localPagination.isLoading = false
            localPagination.incrementOffset()
            state = .success
        }
    }
    
    private func fetchLocalFavoritesRecipes() async throws {
        guard favoritesPagination.hasMoreData else { return }
            favoritesPagination.isLoading = true
        defer { favoritesPagination.isLoading = false }
        
        let recipeDomains = try await service.fetchFavorites(
                startIndex: 0,
                pageSize: favoritesPagination.pageSize
            )
        
        let storedRecipes = recipeDomains.map { Recipe(from: $0) }
        
        favoriteRecipes = storedRecipes
        if !storedRecipes.isEmpty {
            favoritesPagination.isLoading = false
            favoritesPagination.incrementOffset()
        }
        state = .success
    }
    
    private func fetchRemoteRecipes() async throws {
        guard !remotePagination.isLoading else { return }
        
        remotePagination.isLoading = true
        defer { remotePagination.isLoading = false }
        
        let results = try await service.fetchRecipes(
            endPoint: .recipes(
                startIndex: remotePagination.currentPage,
                pageSize: Constants.Recipe.fetchLimit
            )
        )
                
        updateRemoteRecipes(with: results)
        try await updateRemotePagination()
    }
    
    private func updateRemoteRecipes(with fetchedRecipes: (inserted: [RecipeModel], updated: [RecipeModel])) {
        let newRecipes = fetchedRecipes.inserted.map { Recipe(from: $0) }
        let updatedRecipes = fetchedRecipes.updated.map { Recipe(from: $0) }
        
        otherRecipes.append(contentsOf: newRecipes)
        
        for recipe in updatedRecipes {
            if let index = otherRecipes.firstIndex(where: { $0.id == recipe.id }) {
                otherRecipes[index] = recipe
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
        if let index = otherRecipes.firstIndex(where: { $0.id == recipeID }) {
            var movedRecipe = otherRecipes.remove(at: index)
            movedRecipe.isFavorite = true
            favoriteRecipes.append(movedRecipe)
        } else if let index = favoriteRecipes.firstIndex(where: { $0.id == recipeID }) {
            var movedRecipe = favoriteRecipes.remove(at: index)
            movedRecipe.isFavorite = false
            otherRecipes.append(movedRecipe)
        }
    }
}

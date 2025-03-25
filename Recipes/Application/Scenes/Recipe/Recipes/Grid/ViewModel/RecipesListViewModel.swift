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
    var favoriteRecipes: [Recipe] { get }
    var otherRecipes: [Recipe] { get }
    var isEmpty: Bool { get }
    var remotePagination: RemotePaginationHandlerType { get }
    var localPagination: LocalPaginationHandlerType { get }
    var recipeListActionSubject: PassthroughSubject<RecipeListAction, Never> { get  set }
    var state: ResultState { get }
    
    func send(_ action: RecipeListAction)
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
        
        Task { try await updateFavoritesPagination() }
        Task { try await updateLocalPagination() }
        Task { try await updateRemotePagination() }
        listeningFavoritesChanges()
    }
    
    func send(_ action: RecipeListAction) {
        switch action {
        case .refresh:
            if favoritesPagination.hasMoreData {
                Task { try await fetchLocalFavoritesRecipes() }
            }
            
            if localPagination.hasMoreData {
                Task { try await fetchLocalRecipes() }
            } else if remotePagination.hasMoreData {
                Task { try await fetchRemoteRecipes() }
            }
        case .loadMore:
            Task {
                do {
                    if favoritesPagination.hasMoreData {
                        try await fetchLocalFavoritesRecipes()
                    }
                    
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
}

private extension RecipeListViewModel {
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
    
    private func updateFavoritesPagination() async throws {
        let count = try await service.fetchFavoritesRecipesCount()
        favoritesPagination.updateTotalItems(count)
    }
    
    private func updateLocalPagination() async throws {
        let count = try await service.fetchRecipesCount()
        localPagination.updateTotalItems(count)
    }
    
    private func fetchLocalRecipes() async throws {
        Task {
            localPagination.isLoading = true
            
            do {
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
            } catch {
                localPagination.isLoading = false
                state = .failed(error: error)
            }
        }
    }
    
    private func fetchLocalFavoritesRecipes() async throws {
        Task {
            
            favoritesPagination.isLoading = true
            
            do {
                let recipeDomains = try await service.fetchFavorites(
                        startIndex: 0,
                        pageSize: favoritesPagination.pageSize
                    )
                
                let storedRecipes = recipeDomains.map { Recipe(from: $0) }
                
                favoriteRecipes = storedRecipes
                if !storedRecipes.isEmpty {
                    favoritesPagination.isLoading = false
                    favoritesPagination.incrementOffset()
                    state = .success
                }
            } catch {
                print("no favorites found. handle later \(error)")
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
                if otherRecipes.count == 0 {
                    remotePagination.isLoading = false
                    state = .failed(error: error)
                }
            }
        }
    }
    
    private func updateRemoteRecipes(with fetchedRecipes: (inserted: [RecipeDomain], updated: [RecipeDomain])) {
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

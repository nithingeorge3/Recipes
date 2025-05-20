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
    var recipes: [Recipe] { get }
    var isEmpty: Bool { get }
    var remotePagination: RemotePaginationHandlerType { get }
    var localPagination: LocalPaginationHandlerType { get }
    var recipeActionSubject: PassthroughSubject<RecipeAction, Never> { get  set }
    var state: ResultState { get }
    
    func send(_ action: RecipeAction) async
    func loadInitialData() async
}

@Observable
class RecipeListViewModel: RecipesListViewModelType {
    var state: ResultState = .loading
    let service: RecipeServiceProvider
    var remotePagination: RemotePaginationHandlerType
    var localPagination: LocalPaginationHandlerType
    var recipeActionSubject = PassthroughSubject<RecipeAction, Never>()
    
    private var updateTask: Task<Void, Never>?
    private var emptyRecipeMessage = "No recipes found. Please try again later."
    
    var recipes: [Recipe] = []
       
    var isEmpty: Bool {
        recipes.isEmpty &&
        !remotePagination.isLoading &&
        !localPagination.isLoading
    }
    
    init(
        service: RecipeServiceProvider,
        remotePagination: RemotePaginationHandlerType,
        localPagination: LocalPaginationHandlerType
    ) {
        self.service = service
        self.remotePagination = remotePagination
        self.localPagination = localPagination
        print("*** service: \(service)")
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
        async let updateLocalPagination: Void = updateLocalPagination()
        async let updateRemotePagination: Void = updateRemotePagination()
        
        do {
            _ = try await (updateLocalPagination, updateRemotePagination)
        } catch {
            print("error while updating pagination \(error)")
        }
    }
}

private extension RecipeListViewModel {
    private func fetchRecipes() async {
        let hasMoreLocal = localPagination.hasMoreData
        let hasMoreRemote = remotePagination.hasMoreData
        
        async let localOrRemote: Void? = hasMoreLocal
                                        ? fetchLocalRecipes()
                                        : (hasMoreRemote ? fetchRemoteRecipes() : nil)
        
        do {
            _ = try await (localOrRemote)
        } catch {
            if recipes.count == 0 {
                state = .failed(error: error)
            }
            print("error fetching recipes: \(error)")
        }
    }
    
    private func updateRemotePagination() async throws {
        let paginationDomain = try await service.fetchPagination(.recipe)
        remotePagination.updateFromDomain(Pagination(from: paginationDomain))
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
            recipes.append(contentsOf: storedRecipes)
            localPagination.isLoading = false
            localPagination.incrementOffset()
            state = .success
        }
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
        
        recipes.append(contentsOf: newRecipes)
        
        for recipe in updatedRecipes {
            if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
                recipes[index] = recipe
            }
        }
        
        remotePagination.isLoading = false
        state = .success
    }
}

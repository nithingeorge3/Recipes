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
    var navTitle: String { get set }
    var remotePagination: RemotePaginationHandlerType { get }
    var localPagination: LocalPaginationHandlerType { get }
    var searchPagination: LocalPaginationHandlerType { get }
    var recipeActionSubject: PassthroughSubject<RecipeAction, Never> { get  set }
    var state: ResultState { get }
    
    //search
    var searchText: String { get set }
    var searchTask: Task<Void, Never>? { get set }
    var isSearching: Bool { get }
        
    func send(_ action: RecipeAction) async
    func loadInitialData() async
}

@Observable
class RecipeListViewModel: RecipesListViewModelType {
    var state: ResultState = .loading
    let service: RecipeServiceProvider
    var remotePagination: RemotePaginationHandlerType
    var localPagination: LocalPaginationHandlerType
    var searchPagination: LocalPaginationHandlerType
    
    var recipeActionSubject = PassthroughSubject<RecipeAction, Never>()
    
    private var updateTask: Task<Void, Never>?
    private var emptyRecipeMessage = "No recipes found. Please try again later."
    var navTitle = "Recipes"
    
    var recipes: [Recipe] = []
    private var originalRecipes: [Recipe] = []
    
    var searchTask: Task<Void, Never>?
    
    var isEmpty: Bool {
        recipes.isEmpty &&
        !remotePagination.isLoading &&
        !localPagination.isLoading
    }
    
    var searchText = "" {
        didSet {
            searchTask?.cancel()
            searchTask = Task {
                try? await Task.sleep(for: .milliseconds(300))
                guard !Task.isCancelled else { return }
                searchPagination.newQuery(searchText)
                recipes.removeAll()
                await searchRecipes()
            }
        }
    }
    
    var isSearching: Bool = false
    
    init(
        service: RecipeServiceProvider,
        remotePagination: RemotePaginationHandlerType,
        localPagination: LocalPaginationHandlerType,
        searchPagination: LocalPaginationHandlerType
    ) {
        self.service = service
        self.remotePagination = remotePagination
        self.localPagination = localPagination
        self.searchPagination = searchPagination
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
    
    private func searchRecipes() async {
        guard !searchText.isEmpty else {
            await resetSearch()
            return
        }
        
        isSearching = true
        
        let filtered = originalRecipes.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
        
        if !filtered.isEmpty {
            recipes = filtered
            state = filtered.isEmpty ? .empty(message: "No matches found") : .success
            isSearching = false
            return
        }
        
        do {
            let start = searchPagination.currentOffset
            let size  = searchPagination.pageSize

            let results = try await service.searchRecipes(
                query: searchText,
                startIndex: start,
                pageSize: size
            )
            
            recipes.append(contentsOf: results.map(Recipe.init))
            searchPagination.incrementOffset()
            searchPagination.updateHasMoreData(receivedCount: results.count)
            state = recipes.isEmpty ? .empty(message: "No matches found") : .success
        } catch {
            state = .failed(error: RecipeError.searchFailed("search failed"))
        }
        
        isSearching = false
    }
}

private extension RecipeListViewModel {
    private func fetchRecipes() async {
        if !searchText.isEmpty {
            await fetchSearchResults()
        } else {
            let hasMoreLocal = localPagination.hasMoreData
            let hasMoreRemote = remotePagination.hasMoreData
            
            async let localOrRemote: Void? = hasMoreLocal
                                            ? fetchLocalRecipes()
                                            : (hasMoreRemote ? fetchRemoteRecipes() : nil)
            
            do {
                _ = try await (localOrRemote)
            } catch {
                if recipes.count == 0 {
                    state = .failed(error: RecipeError.fetchFailed("recipe fetch failed"))
                }
                print("error fetching recipes: \(error)")
            }
        }
    }
    
    private func fetchSearchResults() async {
        guard searchPagination.hasMoreData else { return }
        
        do {
            let results = try await service.searchRecipes(
                query: searchText,
                startIndex: searchPagination.currentOffset,
                pageSize: searchPagination.pageSize
            )
            
            let newRecipes = results.map { Recipe(from: $0) }
            recipes.append(contentsOf: newRecipes)
            localPagination.incrementOffset()
            state = recipes.isEmpty ? .empty(message: "No matches found") : .success
        } catch {
            state = .failed(error: RecipeError.searchFailed("recipe search failed"))
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
            originalRecipes.append(contentsOf: storedRecipes)
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
        
        if results.inserted.isEmpty && results.updated.isEmpty && recipes.isEmpty {
            state = .empty(message: emptyRecipeMessage)
            return
        }
        updateRemoteRecipes(with: results)
        try await updateRemotePagination()
    }
    
    private func resetSearch() async {
        recipes = originalRecipes
        state = originalRecipes.isEmpty ? .empty(message: emptyRecipeMessage) : .success
    }
    
    private func updateRemoteRecipes(with fetchedRecipes: (inserted: [RecipeModel], updated: [RecipeModel])) {
        let newRecipes = fetchedRecipes.inserted.map { Recipe(from: $0) }
        let updatedRecipes = fetchedRecipes.updated.map { Recipe(from: $0) }
                
        recipes.append(contentsOf: newRecipes)
        originalRecipes.append(contentsOf: newRecipes)
                
        for recipe in updatedRecipes {
            if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
                recipes[index] = recipe
            }
        }
        
        remotePagination.isLoading = false
        state = .success
    }
}

//
//  RecipeService.swift
//  RecipeNetworking
//
//  Created by Nitin George on 01/03/2024.
//

import Combine
import Foundation
import RecipeDomain

final class RecipeService: RecipeServiceProvider {
    private let recipeRepository: RecipeRepositoryType
    
    private let favoritesEventService: FavoritesEventServiceType
    
    public lazy var favoriteDidChange = {
        favoritesEventService.favoriteDidChange
            .eraseToAnyPublisher()
    }()
    
    init(recipeRepository: RecipeRepositoryType, favoritesEventService: FavoritesEventServiceType) {
        self.recipeRepository = recipeRepository
        self.favoritesEventService = favoritesEventService
    }

    func fetchRecipes(endPoint: EndPoint) async throws(NetworkError) -> (inserted: [RecipeModel], updated: [RecipeModel]) {
        do {
            return try await recipeRepository.fetchRecipes(endPoint: endPoint)
            //add business logic
        } catch {
            throw NetworkError.failedToDecode
        }
    }
}

//SwiftData
extension RecipeService {
    func fetchRecipesCount() async throws -> Int {
        try await recipeRepository.fetchRecipesCount()
    }
    
    func fetchFavoritesRecipesCount() async throws -> Int {
        try await recipeRepository.fetchFavoritesRecipesCount()
    }
    
    func fetchRecipe(for recipeID: Int) async throws -> RecipeModel {
        try await recipeRepository.fetchRecipe(for: recipeID)
    }
    
    func fetchRecipes(startIndex: Int = 0, pageSize: Int = 40) async throws -> [RecipeModel] {
        try await recipeRepository.fetchRecipes(startIndex: startIndex, pageSize: pageSize)
    }
    
    func fetchFavorites(startIndex: Int = 0, pageSize: Int = 40) async throws -> [RecipeModel] {
        try await recipeRepository.fetchFavorites(startIndex: startIndex, pageSize: pageSize)
    }
    
    func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool {
        let isUpdated = try await recipeRepository.updateFavouriteRecipe(recipeID)
        favoritesEventService.favoriteDidChange.send(recipeID) 
        return isUpdated
    }
    
    func fetchPagination(_ entityType: EntityType) async throws -> PaginationDomain {
        return try await recipeRepository.fetchPagination(entityType)
    }
}


//just added for showing combine
final class RecipeListServiceImp: RecipeListServiceType {
    private let recipeRepository: RecipeListRepositoryType
    private var cancellables: Set<AnyCancellable> = []

            
    init(recipeRepository: RecipeListRepositoryType) {
        self.recipeRepository = recipeRepository
    }
    
    func fetchRecipes(endPoint: EndPoint) -> Future<[RecipeModel], Error> {
        return Future<[RecipeModel], Error> { [weak self] promise in
            guard let self = self else {
                return promise(.failure(NetworkError.contextDeallocated))
            }
            recipeRepository.fetchRecipes(endPoint: endPoint)
                .receive(on: RunLoop.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        promise(.failure(error))
                    }
                } receiveValue: { recipes in
                    promise(.success(recipes))
                }
                .store(in: &cancellables)
        }
    }
}

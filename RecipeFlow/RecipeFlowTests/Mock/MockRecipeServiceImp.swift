//
//  MockRecipeService.swift
//  Recipes
//
//  Created by Nitin George on 06/03/2025.
//

import XCTest
import Foundation
import RecipeNetworking
import RecipeData
import RecipeDomain
import Combine

@testable import RecipeFlow

final class MockRecipeService: RecipeServiceProvider, @unchecked Sendable {
    var resultsJSON: String
    var stubbedRecipes: [RecipeModel] = []
    var searchResults: [RecipeModel] = []
    var shouldThrowError: Bool = false
      
    private let favoritesEventService: FavoritesEventServiceType
    
    public var favoriteDidChange: AnyPublisher<Int, Never> {
        favoritesEventService.favoriteDidChange
            .eraseToAnyPublisher()
    }
    
    init(
        mockJSON: String = JSONData.recipeValidJSON,
        favoritesEventService: FavoritesEventServiceType = MockFavoritesEventService()
    ) {
        self.resultsJSON = mockJSON
        self.favoritesEventService = favoritesEventService
    }
    
    func triggerFavoriteChange(recipeID: Int) {
    }
        
    func fetchRecipesCount() async throws -> Int {
        stubbedRecipes.count
    }
    
    func fetchFavoritesRecipesCount() async throws -> Int {
        stubbedRecipes.count(where: \.isFavorite)
    }
    
    func fetchFavorites(startIndex: Int, pageSize: Int) async throws -> [RecipeModel] {
        stubbedRecipes.filter { $0.isFavorite }
    }
    
    func fetchRecipe(for recipeID: Int) async throws -> RecipeModel {
        guard var recipe = stubbedRecipes.first else {
            throw RecipeError.notFound(recipeID: recipeID)
        }
        
        recipe.isFavorite = true
        return recipe
    }
    
    func fetchRecipes(startIndex: Int, pageSize: Int) async throws -> [RecipeModel] {
        return stubbedRecipes
    }
    
    func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool {
        guard let index = stubbedRecipes.firstIndex(where: { $0.id == recipeID }) else {
            throw RecipeError.notFound(recipeID: recipeID)
        }
        
        stubbedRecipes[index].isFavorite.toggle()
        
        favoritesEventService.favoriteDidChange.send(recipeID)
        
        return stubbedRecipes[index].isFavorite
    }
    
    func fetchPagination(_ type: EntityType) async throws -> PaginationDomain {
        PaginationDomain()
    }
    
    func fetchRecipes(endPoint: EndPoint = .recipes(startIndex: 0, pageSize: 40)) async throws -> (inserted: [RecipeModel], updated: [RecipeModel]) {
        do {
            if let data = resultsJSON.data(using: .utf8) {
                let decoder = JSONDecoder()
                let dtos = try decoder.decode(MockRecipeResponseDTO.self, from: data)
                
                let recipeDomains = dtos.results.map { RecipeModel(from: $0) }
                stubbedRecipes = recipeDomains
                return (stubbedRecipes, [])
            }
        } catch {
            throw NetworkError.failedToDecode
        }
        
        return (stubbedRecipes, [])
    }
    
    func searchRecipes(query: String, startIndex: Int, pageSize: Int) async throws -> [RecipeModel] {
        if shouldThrowError {
            throw RecipeError.searchFailed("Search failed")
        }
        
        let filtered = searchResults.filter { $0.name.localizedCaseInsensitiveContains(query) }
        return Array(filtered.dropFirst(startIndex).prefix(pageSize))
    }
}


struct MockRecipeResponseDTO: Codable {
    let count: Int
    let results: [MockRecipeDTO]
}

struct MockRecipeDTO: Codable {
    let id: Int
    let name: String
    let country: MockCountryDTO?
    let description: String?
    let thumbnailURL: String?
    let originalVideoURL: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case country
        case description
        case thumbnailURL = "thumbnail_url"
        case originalVideoURL = "original_video_url"
    }
}

enum MockCountryDTO: String, Codable {
    case us = "US"
    case unknown
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = MockCountryDTO(rawValue: rawValue) ?? .unknown
    }
}

extension RecipeModel {
    init(from dto: MockRecipeDTO) {
        self.init(
            id: dto.id,
            name: dto.name,
            description: dto.description,
            country: .gb,
            thumbnailURL: dto.thumbnailURL,
            originalVideoURL: dto.originalVideoURL
        )
    }
}

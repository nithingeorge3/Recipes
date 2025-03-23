//
//  MockRecipeServiceImp.swift
//  Recipes
//
//  Created by Nitin George on 06/03/2025.
//

import XCTest
import Foundation
import RecipeNetworking
import RecipeDataStore
import RecipeDomain

@testable import Recipes

final class MockRecipeServiceImp: RecipeServiceProvider, @unchecked Sendable {
    var resultsJSON: String
    var stubbedRecipes: [RecipeDomain] = []
    var shouldThrowError: Bool = false
        
    private let (stream, continuation) = AsyncStream.makeStream(of: Int.self)
    
    init(mockJSON: String = JSONData.recipeValidJSON) {
        self.resultsJSON = mockJSON
    }
    
    func triggerFavoriteChange(recipeID: Int) {
    }
    
    var favoritesDidChange: AsyncStream<Int> { stream }
    
    func fetchRecipesCount() async throws -> Int {
        stubbedRecipes.count
    }
    
    func fetchRecipe(for recipeID: Int) async throws -> RecipeDomain {
        guard let recipe = stubbedRecipes.first else {
            throw RecipeError.notFound(recipeID: recipeID)
        }
        return recipe
    }
    
    func fetchRecipes(startIndex: Int, pageSize: Int) async throws -> [RecipeDomain] {
        return stubbedRecipes
    }
    
    func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool {
        guard let index = stubbedRecipes.firstIndex(where: { $0.id == recipeID }) else {
            throw RecipeError.notFound(recipeID: recipeID)
        }
        
        stubbedRecipes[index].isFavorite.toggle()
        return stubbedRecipes[index].isFavorite
    }
    
    func fetchPagination(_ type: EntityType) async throws -> PaginationDomain {
        PaginationDomain()
    }
    
    func fetchRecipes(endPoint: EndPoint = .recipes(startIndex: 0, pageSize: 40)) async throws -> (inserted: [RecipeDomain], updated: [RecipeDomain]) {
        do {
            if let data = resultsJSON.data(using: .utf8) {
                let decoder = JSONDecoder()
                let dtos = try decoder.decode(MockRecipeResponseDTO.self, from: data)
                
                let recipeDomains = dtos.results.map { RecipeDomain(from: $0) }
                stubbedRecipes = recipeDomains
                return (stubbedRecipes, [])
            }
        } catch {
            throw NetworkError.failedToDecode
        }
        
        return (stubbedRecipes, [])
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

extension RecipeDomain {
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

//
//  MockRecipeRepository.swift
//  RecipeNetworking
//
//  Created by Nitin George on 06/03/2025.
//

import Foundation
import RecipeDomain

final class RecipeNetBundle {
    public static let bundle = Bundle(for: RecipeNetBundle.self)
}

final class MockRecipeRepository: RecipeRepositoryType, @unchecked Sendable {
    private let fileName: String
    private let parser: ServiceParserType
    private var recipe: RecipeModel?
    private var recipes: [RecipeModel] = []
    private var pagination: PaginationDomain
    
    init(
        fileName: String,
        parser: ServiceParserType = ServiceParser(),
        pagination: PaginationDomain = PaginationDomain(id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, entityType: .recipe, totalCount: 0, currentPage: 0, lastUpdated: Date(timeIntervalSince1970: 0))
    ) {
        self.fileName = fileName
        self.parser = parser
        self.pagination = pagination
    }
    
    func fetchRecipes(endPoint: EndPoint) async throws -> (inserted: [RecipeModel], updated: [RecipeModel]) {
        guard let url = RecipeNetBundle.bundle.url(forResource: self.fileName, withExtension: "json") else {
            throw NetworkError.responseError
        }
        
        do {
            let data = try Data(contentsOf: url)
            
            guard let mockResponse = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ) else {
                throw NetworkError.responseError
            }
            
            let dtos = try await parser.parse(data: data, response: mockResponse, type: RecipeResponseDTO.self)
            let recipeDomains = dtos.results.map { RecipeModel(from: $0) }
            
            recipe = recipeDomains.first
            pagination.totalCount = dtos.count
            pagination.currentPage = 1
            recipes = recipeDomains
            
            return (recipeDomains, [])
        }
        catch {
            throw NetworkError.failedToDecode
        }
    }
}

extension MockRecipeRepository {
    func fetchRecipesCount() async throws -> Int {
        recipes.count
    }
    
    func fetchFavoritesRecipesCount() async throws -> Int {
        0
    }
    
    func fetchRecipe(for recipeID: Int) async throws -> RecipeModel {
        guard let recipe = recipe else {
            throw RecipeError.notFound(recipeID: recipeID)
        }
        return recipe
    }
    
    func fetchRecipes(startIndex: Int, pageSize: Int) async throws -> [RecipeModel] {
        []
    }
    
    func fetchFavorites(startIndex: Int, pageSize: Int) async throws -> [RecipeModel] {
        []
    }
    
    func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool {
        guard var recipe = recipe, recipe.id == recipeID else {
            return false
        }
        recipe.isFavorite.toggle()
        self.recipe = recipe
        return recipe.isFavorite
    }
    
    func fetchPagination(_ entityType: EntityType) async throws -> PaginationDomain {
        pagination
    }
    
    func searchRecipes(query: String, startIndex: Int, pageSize: Int) async throws -> [RecipeDomain.RecipeModel] {
        []
    }
}

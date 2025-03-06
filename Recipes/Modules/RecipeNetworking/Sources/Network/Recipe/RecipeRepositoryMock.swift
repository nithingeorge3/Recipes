//
//  RecipeRepositoryMock.swift
//  RecipeNetworking
//
//  Created by Nitin George on 06/03/2025.
//

import Foundation
import RecipeDomain

final class RecipeRepositoryMock: RecipeRepositoryType {
    
    private let fileName: String
    private let parser: ServiceParserType
    
    init(fileName: String, parser: ServiceParserType = ServiceParser()) {
        self.fileName = fileName
        self.parser = parser
    }
    
    func fetchRecipes(endPoint: EndPoint) async throws -> [RecipeDomain] {
        guard let url = Bundle.module.url(forResource: self.fileName, withExtension: "json") else {
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
            let recipeDomains = dtos.results.map { RecipeDomain(from: $0) }
            
            return recipeDomains
        }
        catch {
            throw NetworkError.failedToDecode
        }
    }
    
    func fetchRecipes(page: Int, pageSize: Int) async throws -> [RecipeDomain] {
        []
    }
    
    func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool {
        true
    }
    
    func fetchRecipePagination(_ pagination: PaginationDomain) async throws -> PaginationDomain {
        PaginationDomain(entityType: .recipe)
    }
}

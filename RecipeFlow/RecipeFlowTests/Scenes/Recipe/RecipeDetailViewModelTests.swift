//
//  RecipeDetailViewModelTests.swift
//  RecipesTests
//
//  Created by Nitin George on 07/03/2025.
//

import XCTest
import RecipeDomain
import RecipeNetworking
import RecipeCore

@testable import RecipeFlow

@MainActor
final class RecipeDetailViewModelTests: XCTestCase {
    private var viewModel: RecipeDetailViewModelType!
    private var service: RecipeServiceProvider!
    
    override func setUp() {
        super.setUp()
        service = MockRecipeService()
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
        service = nil
    }
    
    func testInvalidRecipeFetch() async {
        let invalidRecipeID: Recipe.ID = 101000
        
        viewModel = RecipeDetailViewModel(
            recipeID: invalidRecipeID,
            service: service
        )
        
        XCTAssertEqual(viewModel.state, .loading)
        
        await viewModel.send(.loadRecipe)
        
        let expectation = XCTestExpectation(description: "Fetch completes")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 1)
        
        if case let .error(error) = viewModel.state {
            XCTAssertEqual(error, RecipeError.notFound(recipeID: 1))
        } else {
            XCTFail("Expected error state")
        }
        
        XCTAssertEqual(viewModel.navigationTitle, "Recipe Details")
    }
    
    func testSuccessfulRecipeFetch() async throws {
        _ = try await service.fetchRecipes(endPoint: .recipes(startIndex: 0, pageSize: 40))
        
        viewModel = RecipeDetailViewModel(
            recipeID: 1,
            service: service
        )
                
        await viewModel.send(.loadRecipe)
                
        if case let .loaded(recipe) = viewModel.state {
            XCTAssertEqual(recipe.id, 1)
            XCTAssertEqual(recipe.name, "Pasta")
        } else {
            XCTFail("Expected loaded state")
        }
        
        XCTAssertEqual(viewModel.navigationTitle, "Pasta")
    }
    
    func testFavoriteToggle() async throws {
        _ = try await service.fetchRecipes(endPoint: .recipes(startIndex: 0, pageSize: 40))
        
        viewModel = RecipeDetailViewModel(
            recipeID: 1,
            service: service
        )
        
        await viewModel.send(.loadRecipe)
                
        if case let .loaded(recipe) = viewModel.state {
            XCTAssertFalse(recipe.isFavorite)
        } else {
            XCTFail("Recipe should be loaded")
        }
        
        await viewModel.send(.toggleFavorite)
                
        if case let .loaded(updatedRecipe) = viewModel.state {
            XCTAssertTrue(updatedRecipe.isFavorite)
        } else {
            XCTFail("Recipe should be loaded after toggle")
        }
    }
}

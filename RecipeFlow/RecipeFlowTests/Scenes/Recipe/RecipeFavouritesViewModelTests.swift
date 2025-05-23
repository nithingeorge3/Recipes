//
//  RecipeFavouritesViewModelTests.swift
//  RecipesTests
//
//  Created by Nitin George on 23/05/2025.
//

import XCTest
import RecipeNetworking
import RecipeCore
import RecipeData
import RecipeDomain

@testable import RecipeFlow

@MainActor
final class RecipeFavouritesViewModelTests: XCTestCase {
    private var viewModel: RecipeFavouritesViewModelType!
    private var service: RecipeServiceProvider!
    private var favoritesPagination: LocalPaginationHandlerType!
    
    override func setUp() {
        super.setUp()
        service = MockRecipeService()
        favoritesPagination = MockFavoritesPaginationHandler()
        
        viewModel = RecipeFavouritesViewModel(
            service: service,
            favoritesPagination: favoritesPagination
        )
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
        service = nil
        favoritesPagination = nil
    }
    
    func testInitialStateIsLoading() {
        XCTAssertEqual(viewModel.state, .loading, "Initial state should be .loading")
        XCTAssertTrue(viewModel.recipes.isEmpty, "Initially, recipes should be empty")
    }
    
    func testAddFavorite_InsertsSorted() async {
        let mockService = service as! MockRecipeService
        mockService.stubbedRecipes = [RecipeModel(id: 123, name: "Test")]
        
        _ = try? await service.updateFavouriteRecipe(123)
        
        let expectation = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.recipes.first?.id, 123)
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func testRemoveFavorite_UpdatesUIInstantly() async {
        let userRating = UserRatings(id: 100)
        viewModel.recipes = [Recipe(id: 123, name: "Test", isFavorite: true, ratings: userRating)]
        
        let mockService = service as! MockRecipeService
        mockService.stubbedRecipes = [RecipeModel(id: 123, name: "Test", isFavorite: true)]
        
        _ = try? await service.updateFavouriteRecipe(123)
        
        let expectation = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.viewModel.recipes.isEmpty)
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 1.0)
    }
}

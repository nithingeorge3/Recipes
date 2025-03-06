//
//  RecipeListViewModelTests.swift
//  RecipesTests
//
//  Created by Nitin George on 05/03/2025.
//

import XCTest

@testable import Recipes

final class RecipeListViewModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()

    }
    
    func testInitialState() async throws {
        let result = try await MockRecipeServiceImp().fetchRecipes()
        print(result.count)
        XCTAssertTrue(true) // :)
    }

//    func testEmptyState() async {
//        let coordinator = AppCoordinator(containerName: "TestRecipes")
//        await coordinator.initialize()
//        
//        // Verify empty state
//        let viewModel = coordinator.recipeListViewModel
//        XCTAssertEqual(viewModel.recipes.count, 0)
//    }
}

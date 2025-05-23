//
//  RecipeListViewModelTests.swift
//  RecipesTests
//
//  Created by Nitin George on 05/03/2025.
//

import XCTest
import RecipeNetworking
import RecipeCore
import RecipeData
import RecipeDomain

@testable import RecipeFlow

@MainActor
final class RecipeListViewModelTests: XCTestCase {
    private var viewModel: RecipesListViewModelType!
    private var service: RecipeServiceProvider!
    private var remotePagination: RemotePaginationHandlerType!
    private var localPagination: LocalPaginationHandlerType!
    private var searchPagination: LocalPaginationHandlerType!
    
    override func setUp() {
        super.setUp()
        service = MockRecipeService()
        remotePagination = MockRemotePaginationHandler()
        localPagination = MockLocalPaginationHandler()
        searchPagination = MockSearchPaginationHandler()
        
        viewModel = RecipeListViewModel(
            service: service,
            remotePagination: remotePagination,
            localPagination: localPagination,
            searchPagination: searchPagination
        )
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
        service = nil
        remotePagination = nil
        localPagination = nil
    }
    
    func testInitialStateIsLoading() {
        XCTAssertEqual(viewModel.state, .loading, "Initial state should be .loading")
        XCTAssertTrue(viewModel.recipes.isEmpty, "Initially, recipes should be empty")
    }
    
    func testRecipesFetch() async {
        XCTAssertEqual(viewModel.state, .loading)
        
        await viewModel.send(.refresh)
        
        if case .success = viewModel.state {
            XCTAssertFalse(viewModel.recipes.isEmpty)
            XCTAssertEqual(viewModel.recipes.count, 4)
        } else {
            XCTFail("Expected error state")
        }
        
        XCTAssertEqual(viewModel.navTitle, "Recipes")
    }
    
    func testEmptyRecipesFetch() async {
        XCTAssertEqual(viewModel.state, .loading)
        
        service = MockRecipeService(mockJSON: JSONData.recipeEmptyJSON)
        
        viewModel = RecipeListViewModel(
            service: service,
            remotePagination: remotePagination,
            localPagination: localPagination,
            searchPagination: searchPagination
        )
        
        await viewModel.send(.refresh)
        
        if case .empty = viewModel.state {
            XCTAssertTrue(viewModel.recipes.isEmpty)
            XCTAssertEqual(viewModel.recipes.count, 0)
        } else {
            XCTFail("Expected error state")
        }
        
        XCTAssertEqual(viewModel.navTitle, "Recipes")
    }
}

//search test cases
extension RecipeListViewModelTests {
    func testSearch_EmptyQuery_ShowsOriginalRecipes() async {
        await viewModel.send(.refresh)
        let originalCount = viewModel.recipes.count
        
        viewModel.searchQuery = ""
        await viewModel.searchRecipes()
        
        XCTAssertEqual(viewModel.recipes.count, originalCount)
        XCTAssertFalse(viewModel.isSearching)
    }

    func testSearch_FiltersLocalRecipes() async {
        await viewModel.send(.refresh)
        let searchTerm = "Pasta"
        
        viewModel.searchQuery = searchTerm
        await viewModel.searchRecipes()
        
        XCTAssertTrue(viewModel.recipes.allSatisfy { $0.name.contains(searchTerm) })
        XCTAssertEqual(viewModel.state, .success)
    }

    func testSearch_Pagination_AppendsNewResults() async {
        let mockService = service as! MockRecipeService
        mockService.searchResults = Array(repeating: RecipeModel(id: 1, name: "Curry"), count: 20)
        viewModel.searchQuery = "Curry"
        
        await viewModel.searchRecipes()
        let firstPageCount = viewModel.recipes.count
        
        await viewModel.send(.loadMore)
        
        XCTAssertGreaterThan(viewModel.recipes.count, firstPageCount)
        XCTAssertTrue(viewModel.searchPagination.hasMoreData)
    }
    
    func testSearch_ReturnsMatchingRecipes() async {
        let mockService = service as! MockRecipeService
        mockService.searchResults = [
            RecipeModel(id: 1, name: "Chicken Pasta"),
            RecipeModel(id: 2, name: "Chicken Curry"),
            RecipeModel(id: 3, name: "Italian Pasta")
        ]
        
        viewModel.searchQuery = "Chicken"
        await viewModel.searchRecipes()
        
        XCTAssertEqual(viewModel.recipes.count, 2)
        XCTAssertTrue(viewModel.recipes.allSatisfy { $0.name.contains("Chicken") })
    }

    func testSearch_Pagination_AppendsResults() async {
        let mockService = service as! MockRecipeService
        mockService.searchResults = Array(repeating: RecipeModel(id: 1, name: "Matching Recipe"), count: 30)
        viewModel.searchQuery = "Matching"
        
        await viewModel.searchRecipes()
        let firstPageCount = viewModel.recipes.count
        
        await viewModel.send(.loadMore)
        
        XCTAssertGreaterThan(viewModel.recipes.count, firstPageCount)
        XCTAssertTrue(viewModel.searchPagination.hasMoreData)
    }
    
    func testInitialLoad_EmptyResponse_ShowsEmptyState() async {
        service = MockRecipeService(mockJSON: JSONData.recipeEmptyJSON)
        
        viewModel = RecipeListViewModel(
            service: service,
            remotePagination: remotePagination,
            localPagination: localPagination,
            searchPagination: searchPagination
        )
        
        await viewModel.loadInitialData()
        await viewModel.send(.refresh)
        
        if case .empty = viewModel.state {
            XCTAssertTrue(viewModel.isEmpty)
        } else {
            XCTFail("Expected empty state")
        }
    }
    
    func testSearch_ExactMatch() async {
        let mockService = service as! MockRecipeService
        mockService.searchResults = [
            RecipeModel(id: 1, name: "Chicken Tikka Masala")
        ]
        
        viewModel.searchQuery = "Tikka"
        await viewModel.searchRecipes()
        
        XCTAssertEqual(viewModel.recipes.first?.name, "Chicken Tikka Masala")
    }

    func testSearch_CaseInsensitive() async {
        let mockService = service as! MockRecipeService
        mockService.searchResults = [
            RecipeModel(id: 1, name: "PASTA")
        ]
        
        viewModel.searchQuery = "pasta"
        await viewModel.searchRecipes()
        
        XCTAssertFalse(viewModel.recipes.isEmpty)
    }
    
    func testSearch_NoResults_ShowsEmptyState() async {
        let mockService = service as! MockRecipeService
        mockService.searchResults = [
            RecipeModel(id: 1, name: "Pizza")
        ]
        
        viewModel.searchQuery = "Taco"
        await viewModel.searchRecipes()
        
        if case .empty = viewModel.state {
            XCTAssertTrue(viewModel.recipes.isEmpty)
        } else {
            XCTFail("Expected empty state")
        }
    }
}

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
        // Arrange
        await viewModel.send(.refresh) // Load initial data
        let originalCount = viewModel.recipes.count
        
        // Act
        viewModel.searchQuery = ""
        await viewModel.searchRecipes()
        
        // Assert
        XCTAssertEqual(viewModel.recipes.count, originalCount)
        XCTAssertFalse(viewModel.isSearching)
    }

    func testSearch_FiltersLocalRecipes() async {
        // Arrange
        await viewModel.send(.refresh)
        let searchTerm = "Pasta"
        
        // Act
        viewModel.searchQuery = searchTerm
        await viewModel.searchRecipes()
        
        // Assert
        XCTAssertTrue(viewModel.recipes.allSatisfy { $0.name.contains(searchTerm) })
        XCTAssertEqual(viewModel.state, .success)
    }

//    func testSearch_Pagination_AppendsNewResults() async {
//        // Arrange
//        let mockService = service as! MockRecipeService
//        mockService.stubbedRecipes = Array(repeating: RecipeModel(id: 1, name: "Curry"), count: 20)
//        viewModel.searchQuery = "Curry"
//        
//        // Act - First page
//        await viewModel.searchRecipes()
//        let firstPageCount = viewModel.recipes.count
//        
//        // Act - Second page
//        await viewModel.send(.loadMore)
//        
//        // Assert
//        XCTAssertGreaterThan(viewModel.recipes.count, firstPageCount)
//        XCTAssertTrue(viewModel.searchPagination.hasMoreData)
//    }
    
//    func testRefresh_ClearsSearchState() async {
//        // Arrange
//        viewModel.searchQuery = "Pasta"
//        await viewModel.searchRecipes()
//        
//        // Act
//        await viewModel.send(.refresh)
//        
//        // Assert
//        XCTAssertTrue(viewModel.searchQuery.isEmpty)
//        XCTAssertFalse(viewModel.isSearching)
//    }
    
    func testInitialLoad_EmptyResponse_ShowsEmptyState() async {
        // Arrange
        service = MockRecipeService(mockJSON: JSONData.recipeEmptyJSON)
        
        viewModel = RecipeListViewModel(
            service: service,
            remotePagination: remotePagination,
            localPagination: localPagination,
            searchPagination: searchPagination
        )
        
        // Act
        await viewModel.loadInitialData()
        await viewModel.send(.refresh)
        
        // Assert
        if case .empty = viewModel.state {
            XCTAssertTrue(viewModel.isEmpty)
        } else {
            XCTFail("Expected empty state")
        }
    }
}

//pagination
//extension RecipeListViewModelTests {
//    func testLocalPagination_LoadsMoreWhenScrolling() async {
//        // Arrange
//        let mockService = service as! MockRecipeService
//        mockService.stubbedRecipes = Array(repeating: RecipeModel(id: 1, name: "Recipe"), count: 30)
//        
//        // Act - Initial load
//        await viewModel.send(.refresh)
//        let initialCount = viewModel.recipes.count
//        
//        // Act - Load more
//        await viewModel.send(.loadMore)
//        
//        // Assert
//        XCTAssertGreaterThan(viewModel.recipes.count, initialCount)
//        XCTAssertEqual(viewModel.localPagination.currentOffset, 20) // Assuming pageSize = 20
//    }
//
//    func testRemotePagination_FallsBackWhenLocalExhausted() async {
//        // Arrange
//        let mockLocal = localPagination as! MockLocalPaginationHandler
//        mockLocal.hasMoreData = false // Force remote fallback
//        
//        // Act
//        await viewModel.send(.loadMore)
//        
//        // Assert
//        XCTAssertTrue((remotePagination as! MockRemotePaginationHandler).isLoading)
//        XCTAssertEqual(viewModel.state, .success)
//    }
//}

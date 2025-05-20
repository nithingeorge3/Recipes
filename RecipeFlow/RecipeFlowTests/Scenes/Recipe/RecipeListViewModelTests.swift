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

@testable import RecipeFlow

@MainActor
final class RecipeListViewModelTests: XCTestCase {
    private var viewModel: RecipesListViewModelType!
    private var service: RecipeServiceProvider!
    private var remotePagination: RemotePaginationHandlerType!
    private var localPagination: LocalPaginationHandlerType!
    
    override func setUp() {
        super.setUp()
        service = MockRecipeService()
        remotePagination = MockRemotePaginationHandler()
        localPagination = MockLocalPaginationHandler()
        
        viewModel = RecipeListViewModel(
            service: service,
            remotePagination: remotePagination,
            localPagination: localPagination
        )
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
        service = nil
        remotePagination = nil
        localPagination = nil
    }
    
//    func testRecipeName() async {
//        Task {
////            await viewModel.loadInitialData()
//            await viewModel.send(.refresh)
//            print(viewModel.otherRecipes.count)
//            print(viewModel.favoriteRecipes.count)
//        }
//    }
    
    func testInitialStateIsLoading() {
        XCTAssertEqual(viewModel.state, .loading, "Initial state should be .loading")
        XCTAssertTrue(viewModel.recipes.isEmpty, "Initially, recipes should be empty")
    }
}

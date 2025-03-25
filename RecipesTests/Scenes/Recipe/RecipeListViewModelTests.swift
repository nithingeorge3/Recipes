//
//  RecipeListViewModelTests.swift
//  RecipesTests
//
//  Created by Nitin George on 05/03/2025.
//

import XCTest
import RecipeNetworking

@testable import Recipes

@MainActor
final class RecipeListViewModelTests: XCTestCase {
    private var viewModel: RecipesListViewModelType!
    private var service: RecipeServiceProvider!
    private var remotePagination: RemotePaginationHandlerType!
    private var localPagination: LocalPaginationHandlerType!
    private var favoritesPagination: LocalPaginationHandlerType!
    
    override func setUp() {
        super.setUp()
        service = MockRecipeServiceImp()
        remotePagination = MockRemotePaginationHandler()
        localPagination = MockLocalPaginationHandler()
        favoritesPagination = MockFavoritesPaginationHandler()
        
        viewModel = RecipeListViewModel(
            service: service,
            remotePagination: remotePagination,
            localPagination: localPagination,
            favoritesPagination: favoritesPagination
        )
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
        service = nil
        remotePagination = nil
        localPagination = nil
        favoritesPagination = nil
    }

    func testInitialStateIsLoading() {
        XCTAssertEqual(viewModel.state, .loading, "Initial state should be .loading")
        XCTAssertTrue(viewModel.otherRecipes.isEmpty, "Initially, recipes should be empty")
        XCTAssertTrue(viewModel.favoriteRecipes.isEmpty, "Initially, favorite recipes should be empty")
    }
}

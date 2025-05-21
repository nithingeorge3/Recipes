//
//  RecipeListViewSnapTests.swift
//  RecipesTests
//
//  Created by Nitin George on 05/03/2025.
//

import XCTest
import RecipeNetworking
import RecipeCore
import RecipeData
import RecipeUI
import SnapshotTesting

@testable import RecipeFlow

@MainActor
final class RecipeListViewSnapTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInitialStateIsLoading() {
        XCTAssertEqual(1, 1, "success")
    }
    
    func testDefaultDetailView() {
        let viewModel = PreviewDetailViewModel.fullRecipe
        
        let view = RecipeDetailView(viewModel: viewModel)
                    .frame(width: 375, height: 812)
                    .environmentObject(TabBarVisibility())
        
        assertSnapshot(
            matching: view.toVC(),
            as: .image(on: .iPhone13Mini(.portrait)),
            named: "DefaultRecipeDetail"
        )
    }
}

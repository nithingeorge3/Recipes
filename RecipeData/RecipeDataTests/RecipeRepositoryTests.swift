//
//  RecipeRepositoryTests.swift
//  RecipeDataSource
//
//  Created by Nitin George on 06/03/2025.
//

import XCTest
import SwiftData
import RecipeDomain

@testable import RecipeDataStore

final class RecipeRepositoryTests: XCTestCase {
    private var repository: RecipeSDRepositoryType!
    private var container: ModelContainer!
    
    override func setUp() async throws {
        container = DataStoreManagerFactory.makeSharedContainer(for: "TestContainer")
        repository = RecipeSDRepository(container: container)
    }
    
    @MainActor
    override func tearDown() async throws {
        try await clearData()
        container = nil
        repository = nil
    }
    
    @MainActor
    private func clearData() async throws {
        let context = ModelContext(container)
        try context.delete(model: SDRecipe.self)
        try context.save()
    }
}

extension RecipeRepositoryTests {
    func testfetchRecipesCount_1() async throws {
        let recipes = [
            RecipeDomain(id: 1, name: "Kerala Chicken Curry")
            ]
            
        try await saveTestRecipes(recipes)
        
        let fetchedRecipeCount = try await repository.fetchRecipesCount()
        
        XCTAssertEqual(fetchedRecipeCount, 1)
        XCTAssertNotEqual(fetchedRecipeCount, 6)
    }
    
    func testfetchRecipesCount_2() async throws {
        let recipes = [
            RecipeDomain(id: 1, name: "Kerala Chicken Curry", isFavorite: true)
            ]
            
        try await saveTestRecipes(recipes)
        
        let fetchedRecipeCount = try await repository.fetchRecipesCount()
        
        XCTAssertEqual(fetchedRecipeCount, 0)
        XCTAssertNotEqual(fetchedRecipeCount, 6)
    }
    
    func testfetchRecipesCount_3() async throws {
        try await saveTestRecipes()
        
        let fetchedRecipeCount = try await repository.fetchRecipesCount()
        
        XCTAssertEqual(fetchedRecipeCount, 2)
        XCTAssertNotEqual(fetchedRecipeCount, 6)
    }
    
    func testfetchFavoritesRecipes() async throws {
        let recipes = [
            RecipeDomain(id: 1, name: "Kerala Chicken Curry", isFavorite: true)
            ]
            
        try await saveTestRecipes(recipes)
        
        let fetchedRecipeCount = try await repository.fetchFavoritesRecipesCount()
        XCTAssertEqual(fetchedRecipeCount, 1)
        let fetchFavRecipes = try await repository.fetchFavorites(startIndex: 0, pageSize: 40)
        XCTAssertEqual(fetchFavRecipes.first?.name, "Kerala Chicken Curry")
        
    }
    
    func testSaveAndFetchRecipesWithPagination() async throws {
        let recipes = [RecipeDomain(id: 1, name: "Kerala Chicken Curry")]
        
        try await saveTestRecipes(recipes)
        
        let fetchedRecipes = try await repository.fetchRecipes(startIndex: 0, pageSize: 1)
        
        XCTAssertEqual(fetchedRecipes.count, 1)
        XCTAssertEqual(fetchedRecipes.first?.id, 1)
        XCTAssertEqual(fetchedRecipes.first?.name, "Kerala Chicken Curry")
    }
    
    func testSaveAndFetchRecipes() async throws {
        let recipes = [RecipeDomain(id: 1, name: "Kerala Chicken Curry")]
        
        try await saveTestRecipes(recipes)
        
        let fetchedRecipe = try await repository.fetchRecipe(for: recipes.first?.id ?? 0)
        
        XCTAssertEqual(fetchedRecipe.id, 1)
        XCTAssertEqual(fetchedRecipe.name, "Kerala Chicken Curry")
    }
    
    func testFetchRecipesPagination() async throws {
        let recipes = (1...10).map {
            RecipeDomain(
                id: $0,
                name: "Chicken Curry\($0)",
                createdAt: $0
            )
        }
        try await saveTestRecipes(recipes)
        
        let page0 = try await repository.fetchRecipes(startIndex: 0, pageSize: 2)
        let page1 = try await repository.fetchRecipes(startIndex: 1, pageSize: 2)
        
        XCTAssertEqual(page0.count, 2)
        XCTAssertEqual(page0.map(\.id), [1, 2])
        
        XCTAssertEqual(page1.count, 2)
        XCTAssertEqual(page1.map(\.id), [2, 3])
    }
    
    func testUpdateFavoriteRecipe() async throws {
        let recipes = [RecipeDomain(id: 1, name: "Biriyani", isFavorite: false)]
        try await saveTestRecipes(recipes)
        
        let isFavoriteAfterFirstUpdate = try await repository.updateFavouriteRecipe(1)
        XCTAssertTrue(isFavoriteAfterFirstUpdate)
        
        let isFavoriteAfterSecondUpdate = try await repository.updateFavouriteRecipe(1)
        XCTAssertFalse(isFavoriteAfterSecondUpdate)
    }
    
    func testUpdateFavoriteRecipeNotFound() async {
        do {
            _ = try await repository.updateFavouriteRecipe(100)
            XCTFail("Expected an error because the recipe does not exist, but no error found")
        } catch {
            XCTAssertEqual(error as? SDError, SDError.modelObjNotFound)
        }
    }
}

extension RecipeRepositoryTests {
    private func saveTestRecipes(
        _ recipes: [RecipeDomain] = [
            RecipeDomain(id: 1, name: "Kerala Chicken Curry"),
            RecipeDomain(id: 2, name: "Biriyani", isFavorite: false)
            ]
    ) async throws {
        _ = try await repository.saveRecipes(recipes)
    }
}

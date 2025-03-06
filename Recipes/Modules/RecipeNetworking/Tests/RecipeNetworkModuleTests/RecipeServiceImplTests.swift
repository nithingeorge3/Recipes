import XCTest

@testable import RecipeNetworking

class RecipeServiceImplTests: XCTestCase {
    
    private var recipeRepository: RecipeRepositoryType!
    private var recipeServiceImpl: RecipeServiceType!
    
    override func setUp() {
    }
    
    override func tearDown() {
        recipeRepository = nil
        recipeServiceImpl = nil
    }
        
    func testFetchRecipes_SuccessResponse_ReturnRecipe() async throws {
        recipeRepository = RecipeRepositoryMock(fileName: "recipe_success", parser: ServiceParser())
        recipeServiceImpl = RecipeServiceImp(recipeRepository: recipeRepository)
        
        let expectation = XCTestExpectation(description: "Recipe should be fetched successfully with one recipe.")
        
        do {
            let dtos = try await recipeRepository.fetchRecipes(endPoint: .recipes(page: 0, limit: 40))
            XCTAssertEqual(dtos.first?.name, "Low-Carb Avocado Chicken Salad")
            XCTAssertEqual(dtos.count, 1)
            expectation.fulfill()
        } catch {
            XCTFail("Unexpected error happened: \(error)")
        }
    }
    
    func testFetchRecipes__SuccessResponse_ReturnEmptyRecipe() async throws {
        recipeRepository = RecipeRepositoryMock(fileName: "recipe_empty", parser: ServiceParser())
        recipeServiceImpl = RecipeServiceImp(recipeRepository: recipeRepository)
        
        let expectation = XCTestExpectation(description: "Recipe fetch should return an empty list when no recipes are available.")
        
        do {
            let dtos = try await recipeRepository.fetchRecipes(endPoint: .recipes(page: 0, limit: 40))
            XCTAssertEqual(dtos.count, 0)
            expectation.fulfill()
        } catch {
            XCTFail("Unexpected error happened: \(error)")
        }
    }

    func testFetchRecipes_FailureResponse_ReturnError() async throws {
        recipeRepository = RecipeRepositoryMock(fileName: "recipe_error", parser: ServiceParser())
        recipeServiceImpl = RecipeServiceImp(recipeRepository: recipeRepository)
        
        let expectation = XCTestExpectation(description: "Recipe fetch should fail and return an appropriate error")
        
        do {
            _ = try await recipeRepository.fetchRecipes(endPoint: .recipes(page: 0, limit: 40))
            XCTFail("Expected an error but received data instead")
        } catch {
            XCTAssertFalse(false, "expected error happened \(error)")
            expectation.fulfill()
        }
    }
}

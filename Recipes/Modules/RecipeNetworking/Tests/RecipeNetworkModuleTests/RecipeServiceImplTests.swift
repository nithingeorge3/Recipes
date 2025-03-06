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
        
        let expectation = XCTestExpectation(description: "Recipe should be fetched successfully with one recipe")
        
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
        
        let expectation = XCTestExpectation(description: "Recipe fetch should return an empty list when no recipes are available")
        
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
    
    func testUpdateFavouriteRecipe() async throws {
        recipeRepository = RecipeRepositoryMock(fileName: "recipe_success", parser: ServiceParser())
        recipeServiceImpl = RecipeServiceImp(recipeRepository: recipeRepository)
        
        let expectation = XCTestExpectation(description: "Recipe's isFavorite status should update successfully")
        
        do {
            let dtos = try await recipeRepository.fetchRecipes(endPoint: .recipes(page: 0, limit: 40))
            let firstToggle = try await recipeRepository.updateFavouriteRecipe(dtos.first?.id ?? 0)
            XCTAssertTrue(firstToggle, "updated should be true")
            let secondToggle = try await recipeRepository.updateFavouriteRecipe(dtos.first?.id ?? 0)
            XCTAssertFalse(secondToggle, "updated should be false")
            expectation.fulfill()
        } catch {
            XCTFail("Unexpected error happened: \(error)")
        }
    }
    
    func testFetchRecipe() async throws {
        recipeRepository = RecipeRepositoryMock(fileName: "recipe_success", parser: ServiceParser())
        recipeServiceImpl = RecipeServiceImp(recipeRepository: recipeRepository)
        
        let expectation = XCTestExpectation(description: "Recipe should be fetched successfully with one recipe")
        
        do {
            _ = try await recipeRepository.fetchRecipes(endPoint: .recipes(page: 0, limit: 40))
            let savedDto = try await recipeRepository.fetchRecipes(page: 0, pageSize: 40)
            XCTAssertEqual(savedDto.first?.name, "Low-Carb Avocado Chicken Salad")
            XCTAssertEqual(savedDto.count, 1)
            expectation.fulfill()
        } catch {
            XCTFail("Unexpected error happened: \(error)")
        }
    }
    
    func testRecipePagination() async throws {
        recipeRepository = RecipeRepositoryMock(fileName: "recipe_success", parser: ServiceParser())
        recipeServiceImpl = RecipeServiceImp(recipeRepository: recipeRepository)
        
        let expectation = XCTestExpectation(description: "Recipe pagination data should be fetched successfully with expected values")
        
        do {
            _ = try await recipeRepository.fetchRecipes(endPoint: .recipes(page: 0, limit: 40))
            let pagination = try await recipeRepository.fetchRecipePagination(.recipe)
            XCTAssertEqual(pagination.totalCount, 10)
            XCTAssertEqual(pagination.currentPage, 1)
            XCTAssertEqual(pagination.id, UUID(uuidString: "11111111-1111-1111-1111-111111111111")!)
            XCTAssertEqual(pagination.lastUpdated, Date(timeIntervalSince1970: 0))
            expectation.fulfill()
        } catch {
            XCTFail("Unexpected error happened: \(error)")
        }
    }
}

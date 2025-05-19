//
//  PaginationRepositoryTests.swift
//  RecipeDataSource
//
//  Created by Nitin George on 06/03/2025.
//

//import XCTest
//import SwiftData
//import RecipeDomain
//
//@testable import RecipeData
//
//@MainActor
//final class PaginationRepositoryTests: XCTestCase {
//    private var repository: PaginationSDRepositoryType!
//    private var container: ModelContainer!
//    
//    override func setUp() async throws {
//        container = DataStoreManagerFactory.makeSharedContainer(for: "TestContainer")
//        repository = PaginationSDRepository(container: container)
//    }
//    
//    @MainActor
//    override func tearDown() async throws {
//        try await clearData()
//        container = nil
//        repository = nil
//    }
//    
//    @MainActor
//    private func clearData() async throws {
//        let context = ModelContext(container)
//        try context.delete(model: SDPagination.self)
//        try context.save()
//    }
//}
//
//extension PaginationRepositoryTests {
//    func testFetchInitialPagination() async throws {
//        let pagination = try await repository.fetchPagination(.recipe)
//        
//        XCTAssertEqual(pagination.entityType, .recipe)
//        XCTAssertEqual(pagination.totalCount, 40)
//        XCTAssertEqual(pagination.currentPage, 0)
//    }
//    
//    func testUpdateNewPagination() async throws {
//        let pagination = PaginationDomain(
//            entityType: .recipe,
//            totalCount: 100,
//            currentPage: 2
//        )
//        
//        try await repository.updatePagination(pagination)
//        let fetched = try await repository.fetchPagination(.recipe)
//        
//        XCTAssertEqual(fetched.totalCount, 100)
//        XCTAssertEqual(fetched.currentPage, 2)
//    }
//    
//    func testUpdate_ModifiesExisting_Pagination() async throws {
//        let initial = PaginationDomain(entityType: .recipe, totalCount: 50, currentPage: 1)
//        try await repository.updatePagination(initial)
//        
//        let updated = PaginationDomain(entityType: .recipe, totalCount: 50, currentPage: 2)
//        try await repository.updatePagination(updated)
//        let fetched = try await repository.fetchPagination(.recipe)
//        
//        XCTAssertEqual(fetched.currentPage, 2)
//        XCTAssertEqual(fetched.totalCount, 50)
//    }
//}
//
//extension PaginationRepositoryTests {
//    func testLastUpdatedTimestamp() async throws {
//        let startDate = Date()
//        let pagination = PaginationDomain(entityType: .recipe)
//        
//        try await repository.updatePagination(pagination)
//        let fetched = try await repository.fetchPagination(.recipe)
//        
//        XCTAssertGreaterThan(fetched.lastUpdated, startDate)
//        XCTAssertLessThan(fetched.lastUpdated, Date())
//    }
//}

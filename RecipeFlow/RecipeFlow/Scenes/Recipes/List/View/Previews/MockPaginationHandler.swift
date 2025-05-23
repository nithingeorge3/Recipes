//
//  MockPaginationHandler.swift
//  Recipes
//
//  Created by Nitin George on 06/03/2025.
//

import RecipeData

final class MockRemotePaginationHandler: RemotePaginationHandlerType {
    var currentPage: Int = 0
    var totalItems: Int = 0
    var isLoading: Bool = false
    var lastUpdated: Date = Date()
    
    var hasMoreData: Bool = true
    
    func reset() { }
    func updateFromDomain(_ pagination: Pagination) {
        totalItems = pagination.totalCount
        currentPage = pagination.currentPage
        lastUpdated = pagination.lastUpdated
        isLoading = false
    }
}

final class MockLocalPaginationHandler: LocalPaginationHandlerType {
    var currentOffset: Int = 0
    var pageSize: Int = 20
    var totalItems: Int = 0
    var isLoading: Bool = false
    var lastUpdated: Date = Date()

    var hasMoreData: Bool = false
    
    func reset() {
    }
    
    func incrementOffset() {
        currentOffset += pageSize
    }
    
    func updateTotalItems(_ newValue: Int) {
        totalItems = newValue
    }
}

final class MockFavoritesPaginationHandler: LocalPaginationHandlerType {
    var currentOffset: Int = 0
    var pageSize: Int = 0
    var totalItems: Int = 0
    var isLoading: Bool = false
    var lastUpdated: Date = Date()

    var hasMoreData: Bool = false
    
    func reset() {
    }
    
    func incrementOffset() {
        currentOffset += pageSize
    }
    
    func updateTotalItems(_ newValue: Int) {
        totalItems = newValue
    }
}

final class MockSearchPaginationHandler: LocalPaginationHandlerType {
    var currentOffset: Int = 0
    var pageSize: Int = 20
    var totalItems: Int = 40
    var isLoading: Bool = false
    var lastUpdated: Date = Date()
    
    var hasMoreData: Bool = true
    var query: String = ""

    func reset() {
        currentOffset = 0
        isLoading = false
        hasMoreData = true
    }

    func incrementOffset() {
        currentOffset += pageSize
    }

    func updateTotalItems(_ newValue: Int) {
        totalItems = newValue
    }

    func newQuery(_ newValue: String) {
        query = newValue
        reset()
    }

    func updateHasMoreData(receivedCount: Int) {
        hasMoreData = receivedCount == pageSize
    }
}

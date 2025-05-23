//
//  SearchPaginationHandler.swift
//  RecipeData
//
//  Created by Nitin George on 22/05/2025.
//

import Foundation
import Observation

public final class SearchPaginationHandler: LocalPaginationHandlerType {
    public var currentOffset = 0
    public var pageSize: Int
    public var hasMoreData = true
    public var isLoading = false
    public var query: String = ""
    public var totalItems: Int = 40
    public var lastUpdated: Date = Date()
    
    public init(pageSize: Int = 20) {
        self.pageSize = pageSize
    }

    public func incrementOffset() {
        currentOffset += pageSize
    }
    
    public func reset(totalItems: Int) {
        currentOffset = 0
        hasMoreData = totalItems > 0
    }
    
    public func newQuery(_ newValue: String) {
        query = newValue
        currentOffset = 0
        hasMoreData = true
    }
    
    public func updateHasMoreData(receivedCount: Int) {
        hasMoreData = receivedCount == pageSize
    }
    
    public func reset() {
        currentOffset = 0
        isLoading = false
        lastUpdated = Date()
    }
    
    public func updateTotalItems(_ newValue: Int) { }
}

//
//  RemotePaginationHandler.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Foundation
import Observation

@Observable
public final class RemotePaginationHandler: RemotePaginationHandlerType {
    public var currentPage: Int
    public var totalItems: Int
    public var isLoading: Bool
    public var lastUpdated: Date
    
    public init(currentPage: Int = 0, totalItems: Int = 40, isLoading: Bool = false, lastUpdated: Date = Date()) {
        self.currentPage = currentPage
        self.totalItems = totalItems
        self.isLoading = isLoading
        self.lastUpdated = lastUpdated
    }
    
    public var hasMoreData: Bool {
        totalItems > currentPage
    }
    
    public func reset() {
        currentPage = 0
        totalItems = 0
        isLoading = false
        lastUpdated = Date()
    }
    
    public func updateFromDomain(_ pagination: Pagination) {
        totalItems = pagination.totalCount
        currentPage = pagination.currentPage
        lastUpdated = pagination.lastUpdated
        isLoading = false
    }
}

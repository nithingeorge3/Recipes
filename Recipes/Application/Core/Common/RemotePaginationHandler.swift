//
//  RemotePaginationHandler.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Foundation
import Observation

@MainActor
protocol RemotePaginationHandlerType: AnyObject {
    var currentPage: Int { get set }
    var totalItems: Int { get set }
    var hasMoreData: Bool { get }
    var isLoading: Bool { get set }
    var lastUpdated: Date { get set }
    
    func reset()
    func validateLoadMore(index: Int) -> Bool
    func updateFromDomain(_ pagination: Pagination)
}

@Observable
final class RemotePaginationHandler: RemotePaginationHandlerType {
    var currentPage: Int = 0
    var totalItems: Int = 40
    var isLoading: Bool = false
    var lastUpdated: Date = Date()
    
    var hasMoreData: Bool {
        totalItems > currentPage
    }
    
    func reset() {
        currentPage = 0
        totalItems = 0
        isLoading = false
        lastUpdated = Date()
    }
    
    func validateLoadMore(index: Int) -> Bool {
        index == currentPage * Constants.Recipe.fetchLimit - 5 && !isLoading && hasMoreData
    }
    
    func updateFromDomain(_ pagination: Pagination) {
        totalItems = pagination.totalCount
        currentPage = pagination.currentPage
        lastUpdated = pagination.lastUpdated
        isLoading = false
    }
}

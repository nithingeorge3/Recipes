//
//  PaginationState.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Foundation
import Observation

@MainActor
public protocol LocalPaginationHandlerType: AnyObject {
    var currentOffset: Int { get set }
    var pageSize: Int { get set }
    var totalItems: Int { get set }
    var isLoading: Bool { get set }
    var lastUpdated: Date { get set }
    
    var hasMoreData: Bool { get }
    
    func reset()
    func incrementOffset()
    func updateTotalItems(_ newValue: Int)
}

@Observable
public final class LocalPaginationHandler: LocalPaginationHandlerType {
    public var currentOffset: Int
    public var pageSize: Int
    public var totalItems: Int
    public var isLoading: Bool
    public var lastUpdated: Date
    
    public init(currentOffset: Int = 0, pageSize: Int = Constants.Recipe.fetchLimit, totalItems: Int = 0, isLoading: Bool = false, lastUpdated: Date = Date()) {
        self.currentOffset = currentOffset
        self.pageSize = pageSize
        self.totalItems = totalItems
        self.isLoading = isLoading
        self.lastUpdated = lastUpdated
    }
    
    public var hasMoreData: Bool {
        currentOffset < totalItems
    }
    
    public func reset() {
        currentOffset = 0
        isLoading = false
        lastUpdated = Date()
    }
    
    public func incrementOffset() {
        currentOffset += pageSize
    }
    
    public func updateTotalItems(_ newValue: Int) {
        totalItems = newValue
    }
}

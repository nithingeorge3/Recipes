//
//  LocalPaginationHandlerType.swift
//  RecipeData
//
//  Created by Nitin George on 22/05/2025.
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

public extension LocalPaginationHandlerType {
    func decrementTotalItems() { }
    func updateHasMoreData(receivedCount: Int) { }
    func newQuery(_ newValue: String) { }
}

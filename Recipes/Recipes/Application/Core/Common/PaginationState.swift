//
//  PaginationState.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Foundation
import Observation

@MainActor
protocol PaginationStateType {
    var currentPage: Int { get set }
    var isFetching: Bool { get set }
    var hasMoreData: Bool { get set }
    var shouldFetch: Bool { get }
    
    func beginFetch()
    func completeFetch(hasMoreData: Bool)
}

@Observable
class PaginationState: PaginationStateType {
    var currentPage = 0
    var isFetching = false
    var hasMoreData = true
    
    var shouldFetch: Bool { hasMoreData && !isFetching }
    
    func beginFetch() {
        isFetching = true
    }
    
    func completeFetch(hasMoreData: Bool) {
        self.hasMoreData = hasMoreData
        isFetching = false
        currentPage += 1
    }
}

//
//  RemotePaginationHandlerType.swift
//  RecipeData
//
//  Created by Nitin George on 22/05/2025.
//

import Foundation

@MainActor
public protocol RemotePaginationHandlerType: AnyObject {
    var currentPage: Int { get set }
    var totalItems: Int { get set }
    var hasMoreData: Bool { get }
    var isLoading: Bool { get set }
    var lastUpdated: Date { get set }
    
    func reset()
    func updateFromDomain(_ pagination: Pagination)
}
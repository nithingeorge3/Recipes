//
//  PaginationInfo.swift
//  Recipes
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation
import RecipeDomain

public struct Pagination: Identifiable, Hashable {
    public let id: UUID
    public let entityType: EntityType
    public let totalCount: Int
    public var currentPage: Int
    public let lastUpdated: Date
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Pagination, rhs: Pagination) -> Bool {
        lhs.id == rhs.id
    }
    
    public init(id: UUID = UUID(), entityType: EntityType = .recipe, totalCount: Int = 10, currentPage: Int = 10, lastUpdated: Date = Date()) {
        self.id = id
        self.entityType = entityType
        self.totalCount = totalCount
        self.currentPage = currentPage
        self.lastUpdated = lastUpdated
    }
    
    public var shouldFetch: Bool {
        currentPage == totalCount - 1 ? false : true
    }
}

public extension Pagination {
    init(from paginationDomain: PaginationDomain) {
        self.id = paginationDomain.id
        self.entityType = paginationDomain.entityType
        self.totalCount = paginationDomain.totalCount
        self.currentPage = paginationDomain.currentPage
        self.lastUpdated = paginationDomain.lastUpdated
    }
}

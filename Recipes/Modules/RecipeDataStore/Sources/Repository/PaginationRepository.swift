//
//  PaginationRepository.swift
//  RecipeDataStore
//
//  Created by Nitin George on 04/03/2025.
//

import Foundation
import RecipeDomain
import SwiftData

@MainActor
public class PaginationRepository: PaginationRepositoryType {
    private let context: ModelContext
    
    public init(context: ModelContext) {
        self.context = context
    }
    
    public func fetchRecipePagination(_ pagination: PaginationDomain) async throws -> PaginationDomain {
        let type = pagination.entityType
        
        let predicate = #Predicate<SDPagination> { $0.entityTypeRaw == type.rawValue }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        if let existing = try? context.fetch(descriptor).first {
            existing.currentPage += pagination.currentPage
            try context.save()
            return PaginationDomain(from: existing)
        }
        
        let newPagination = SDPagination(
            type: pagination.entityType,
            total: pagination.totalCount,
            page: pagination.currentPage
        )
        context.insert(newPagination)
        
        try context.save()
        
        return PaginationDomain(from: newPagination)
    }
    
    public func updateRecipePagination(_ pagination: PaginationDomain) async throws {
        var container = try await fetchRecipePagination(pagination)
        container.totalCount = pagination.totalCount
        container.currentPage = pagination.currentPage
        container.lastUpdated = pagination.lastUpdated
        
        try context.save()
    }
}

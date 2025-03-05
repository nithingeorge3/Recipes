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
    private let container: ModelContainer
    
    public init(container: ModelContainer) {
        self.container = container
    }
    
    @MainActor
    private var dataStore: DataStoreManager {
        DataStoreManager(container: self.container)
    }
    
    public func fetchRecipePagination(_ pagination: PaginationDomain) async throws -> PaginationDomain {
        try await dataStore.performBackgroundTask { context in
            let type = pagination.entityType
            
            let predicate = #Predicate<SDPagination> { $0.entityTypeRaw == type.rawValue }
            let descriptor = FetchDescriptor(predicate: predicate)
            
            if let existing = try? context.fetch(descriptor).first {
                return PaginationDomain(from: existing)
            }
            
            return PaginationDomain(entityType: .recipe)
        }
    }
    
    public func updateRecipePagination(_ pagination: PaginationDomain) async throws {
        try await dataStore.performBackgroundTask { context in
            let type = pagination.entityType
            let predicate = #Predicate<SDPagination> { $0.entityTypeRaw == type.rawValue }
            let descriptor = FetchDescriptor(predicate: predicate)
            
            if let existing = try? context.fetch(descriptor).first {
                existing.currentPage = pagination.currentPage
                
            } else {
                let newPagination = SDPagination(
                    type: pagination.entityType,
                    total: pagination.totalCount,
                    page: pagination.currentPage
                )
                context.insert(newPagination)
            }
            
            try context.save()
        }
    }
}

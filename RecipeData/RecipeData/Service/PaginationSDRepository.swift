//
//  PaginationSDRepository.swift
//  RecipeData
//
//  Created by Nitin George on 04/03/2025.
//

import Foundation
import RecipeDomain
import SwiftData

protocol PaginationSDRepositoryType: Sendable {
    func fetchPagination(_ entityType: EntityType) async throws -> PaginationDomain
    func updatePagination(_ pagination: PaginationDomain) async throws
}

@MainActor
class PaginationSDRepository: PaginationSDRepositoryType {
    private let container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    @MainActor
    private var dataStore: DataStoreManager {
        DataStoreManager(container: self.container)
    }
    
    func fetchPagination(_ entityType: EntityType) async throws -> PaginationDomain {
        try await dataStore.performBackgroundTask { context in            
            let predicate = #Predicate<SDPagination> { $0.entityTypeRaw == entityType.rawValue }
            let descriptor = FetchDescriptor(predicate: predicate)
            
            if let existing = try? context.fetch(descriptor).first {
                return PaginationDomain(from: existing)
            }
            
            return PaginationDomain(entityType: .recipe)
        }
    }
    
    func updatePagination(_ pagination: PaginationDomain) async throws {
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

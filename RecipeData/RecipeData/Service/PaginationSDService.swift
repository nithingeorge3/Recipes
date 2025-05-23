//
//  PaginationSDRepository.swift
//  RecipeData
//
//  Created by Nitin George on 04/03/2025.
//

import Foundation
import RecipeDomain
import SwiftData

@MainActor
public class PaginationSDService: PaginationSDServiceType {
    private let repository: PaginationSDRepositoryType
    
    init(repository: PaginationSDRepositoryType) {
        self.repository = repository
    }
    
    public func fetchPagination(_ entityType: EntityType) async throws -> PaginationDomain {
        try await repository.fetchPagination(entityType)
    }
    
    public func updatePagination(_ pagination: PaginationDomain) async throws {
        try await repository.updatePagination(pagination)
    }
}

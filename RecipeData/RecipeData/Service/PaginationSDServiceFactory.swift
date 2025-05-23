//
//  PaginationSDRepository.swift
//  RecipeData
//
//  Created by Nitin George on 04/03/2025.
//

import Foundation
import RecipeDomain
import SwiftData

public protocol PaginationSDServiceFactoryType {
    @MainActor func makePaginationSDService(container: ModelContainer) -> PaginationSDServiceType
}

public final class PaginationSDServiceFactory: PaginationSDServiceFactoryType {
    public init() { }
    
    public func makePaginationSDService(container: ModelContainer) -> PaginationSDServiceType {
        let repository = PaginationSDRepository(container: container)
        return PaginationSDService(repository: repository)
    }
}

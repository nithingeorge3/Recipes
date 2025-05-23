//
//  DataStoreManager.swift
//  RecipeData
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation
import SwiftData

@MainActor
public final class DataStoreManager {
    public let container: ModelContainer
    
    public init(container: ModelContainer) {
        self.container = container
    }
    
    @MainActor
    public var mainContext: ModelContext {
        container.mainContext
    }
    
    @MainActor
    func fetchOnMain<T: PersistentModel>(_ type: T.Type) throws -> [T] {
        try mainContext.fetch(FetchDescriptor<T>())
    }
    
    nonisolated func performBackgroundTask<T: Sendable>(
        _ operation: @Sendable @escaping (ModelContext) throws -> T
    ) async throws -> T {
        try await Task.detached(priority: .userInitiated) {
            let backgroundContext = ModelContext(self.container)
            let result = try operation(backgroundContext)
            try backgroundContext.save()
            return result
        }.value
    }
}

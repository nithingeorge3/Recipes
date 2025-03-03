//
//  DataStoreManagerFactory.swift
//  RecipeDataStore
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation
import SwiftData

public protocol DataStoreManagerType: Sendable {
    static func makeNewsDataContext(for containerName: String) -> ModelContext
}

public final class DataStoreManagerFactory: DataStoreManagerType {
    public static func makeNewsDataContext(for containerName: String) -> ModelContext {
        //temp code for testing
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return makeInMemoryContext()
        }
        
        do {
            return try DataStoreManager(containerName: containerName).context
        } catch {
            return makeInMemoryContext()
        }
    }
    
    private static func makeInMemoryContext() -> ModelContext {
        ModelContext(ModelContainer.makeInMemoryContext())
    }
}

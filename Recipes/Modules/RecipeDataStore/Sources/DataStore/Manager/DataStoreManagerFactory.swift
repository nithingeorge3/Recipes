//
//  DataStoreManagerFactory.swift
//  RecipeDataStore
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation
import SwiftData

public protocol DataStoreManagerType: Sendable {
    static func makeSharedContainer(for containerName: String) -> ModelContainer
}

public enum DataStoreManagerFactory {
    public static func makeSharedContainer(_ name: String) -> ModelContainer {
        do {
            return try ModelContainer.buildShared(name)
        } catch {
            print("Error creating container: \(error)")
            return makeInMemoryContainer()
        }
    }
    
    public static func makeInMemoryContainer() -> ModelContainer {
        ModelContainer.makeInMemoryContext()
    }
    
    @MainActor
    public static func makeDataStoreManager(for containerName: String) -> DataStoreManager {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return DataStoreManager(container: makeInMemoryContainer())
        }
        
        return DataStoreManager(container: makeSharedContainer(containerName))
    }
}

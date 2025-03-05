//
//  DataStoreManager.swift
//  RecipeDataStore
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation
import SwiftData

final class DataStoreManager {
    let context: ModelContext
    private let container: ModelContainer
    
    init(containerName: String, container: ModelContainer? = nil) throws {
        if let container = container {
            self.container = container
        } else {
            do {
                self.container = try ModelContainer.buildShared(containerName)
            } catch {
                self.container = try ModelContainer.fallBack()
                print("error creating container: \(error)")
            }
        }
        
        self.context = ModelContext(self.container)
    }
}

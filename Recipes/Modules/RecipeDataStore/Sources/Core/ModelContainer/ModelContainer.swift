//
//  Extension.swift
//  RecipeDataStore
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation
import SwiftData

extension ModelContainer {
    static func buildShared(_ name: String) throws -> ModelContainer {
        let config = ModelConfiguration(
                url: .documentsDirectory.appendingPathComponent("\(name).sqlite"),
                cloudKitDatabase: .none
            )

        let schema = Schema([
            SDRecipe.self,
            SDPagination.self
        ])
        
        return try ModelContainer(
            for: schema,
            configurations: config
        )
    }
    
    static func makeInMemoryContext() -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        
        let schema = Schema([
            SDRecipe.self,
            SDPagination.self
        ])
        
        //ToDo: avoid force unwrapping later
        return try! ModelContainer(
            for: schema,
            configurations: config
        )
    }
    
    static func fallBack() throws -> ModelContainer {
        let config = ModelConfiguration(
            isStoredInMemoryOnly: true
        )
        
        let schema = Schema([
            SDRecipe.self,
            SDPagination.self
        ])
        
        return try ModelContainer(
            for: schema,
            configurations: config
        )
    }
}


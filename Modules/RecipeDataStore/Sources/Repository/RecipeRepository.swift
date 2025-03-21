//
//  RecipeRepository.swift
//  RecipeDataStore
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation
import RecipeDomain
import SwiftData

@frozen
public enum SDError: Error {
    case modelObjNotFound
    case countOperationFailed
}

public final class RecipeSDRepository: RecipeSDRepositoryType {
    private let container: ModelContainer
    
    public init(container: ModelContainer) {
        self.container = container
    }
    
    @MainActor
    private var dataStore: DataStoreManager {
        DataStoreManager(container: self.container)
    }
    
    public func fetchRecipesCount() async throws -> Int {
        try await dataStore.performBackgroundTask { context in
            do {
                let descriptor = FetchDescriptor<SDRecipe>()
                return try context.fetchCount(descriptor)
            } catch {
                throw SDError.countOperationFailed
            }
        }
    }
    
    public func fetchRecipe(for recipeID: Int) async throws -> RecipeDomain {
        try await dataStore.performBackgroundTask { context in
            let predicate = #Predicate<SDRecipe> { $0.id == recipeID }
            let descriptor = FetchDescriptor<SDRecipe>(predicate: predicate)

            guard let recipe = try context.fetch(descriptor).first else {
                throw SDError.modelObjNotFound
            }
            return RecipeDomain(from: recipe)
        }
    }
    
    public func fetchRecipes(startIndex: Int = 0, pageSize: Int = 40) async throws -> [RecipeDomain] {
        try await dataStore.performBackgroundTask { context in
            var descriptor = FetchDescriptor<SDRecipe>(
                predicate: nil,
                sortBy: [SortDescriptor(\.createdAt, order: .forward)]
            )
            descriptor.fetchLimit = pageSize
            descriptor.fetchOffset = startIndex

            return try context.fetch(descriptor).map(RecipeDomain.init)
        }
    }
    
    public func saveRecipes(_ recipes: [RecipeDomain]) async throws -> (inserted: [RecipeDomain], updated: [RecipeDomain]) {
        try await dataStore.performBackgroundTask { context in
            let existing = try self.existingRecipes(ids: recipes.map(\.id), context: context)
            var insertedRecipes: [RecipeDomain] = []
            var updatedRecipes: [RecipeDomain] = []
            
            for recipe in recipes {
                if let existingRecipe = existing[recipe.id] {
                    existingRecipe.update(from: recipe)
                    updatedRecipes.append(recipe)
                } else {
                    context.insert(SDRecipe(from: recipe))
                    insertedRecipes.append(recipe)
                }
            }
            return (insertedRecipes, updatedRecipes)
        }
    }
    
    public func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool {
        try await dataStore.performBackgroundTask { context in
            let predicate = #Predicate<SDRecipe> { $0.id == recipeID }
            let descriptor = FetchDescriptor<SDRecipe>(predicate: predicate)

            guard let existingRecipe = try context.fetch(descriptor).first else {
                throw SDError.modelObjNotFound
            }

            existingRecipe.isFavorite.toggle()

            try context.save()

            return existingRecipe.isFavorite
        }
    }
    
    private func existingRecipes(ids: [Int], context: ModelContext) throws -> [Int: SDRecipe] {
        let predicate = #Predicate<SDRecipe> { ids.contains($0.id) }
        let descriptor = FetchDescriptor<SDRecipe>(predicate: predicate)
        return try context.fetch(descriptor).reduce(into: [:]) { $0[$1.id] = $1 }
    }
}

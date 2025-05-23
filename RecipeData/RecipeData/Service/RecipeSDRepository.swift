//
//  RecipeRepository.swift
//  RecipeData
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

protocol RecipeSDRepositoryType: Sendable {
    func fetchRecipesCount() async throws -> Int
    func fetchFavoritesRecipesCount() async throws -> Int
    func fetchRecipe(for recipeID: Int) async throws -> RecipeModel
    func fetchRecipes(startIndex: Int, pageSize: Int) async throws -> [RecipeModel]
    func fetchFavorites(startIndex: Int, pageSize: Int) async throws -> [RecipeModel]
    func saveRecipes(_ recipes: [RecipeModel]) async throws -> (inserted: [RecipeModel], updated: [RecipeModel])
    func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool
    func searchRecipes(query: String, startIndex: Int, pageSize: Int) async throws -> [RecipeModel]
}


final class RecipeSDRepository: RecipeSDRepositoryType {
    private let container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    @MainActor
    private var dataStore: DataStoreManager {
        DataStoreManager(container: self.container)
    }
    
    func fetchRecipesCount() async throws -> Int {
        try await dataStore.performBackgroundTask { context in
            do {
                let predicate = #Predicate<SDRecipe> { !$0.isFavorite }
                let descriptor = FetchDescriptor<SDRecipe>(predicate: predicate)
                return try context.fetchCount(descriptor)
            } catch {
                throw SDError.countOperationFailed
            }
        }
    }
    
    func fetchFavoritesRecipesCount() async throws -> Int {
        try await dataStore.performBackgroundTask { context in
            do {
                let predicate = #Predicate<SDRecipe> { $0.isFavorite }
                let descriptor = FetchDescriptor<SDRecipe>(predicate: predicate)
                return try context.fetchCount(descriptor)
            } catch {
                throw SDError.countOperationFailed
            }
        }
    }
    
    func fetchRecipe(for recipeID: Int) async throws -> RecipeModel {
        try await dataStore.performBackgroundTask { context in
            let predicate = #Predicate<SDRecipe> { $0.id == recipeID }
            let descriptor = FetchDescriptor<SDRecipe>(predicate: predicate)

            guard let recipe = try context.fetch(descriptor).first else {
                throw SDError.modelObjNotFound
            }
            return RecipeModel(from: recipe)
        }
    }
    
    func fetchRecipes(startIndex: Int = 0, pageSize: Int = 40) async throws -> [RecipeModel] {
        try await dataStore.performBackgroundTask { context in
            let predicate = #Predicate<SDRecipe> { !$0.isFavorite }
            var descriptor = FetchDescriptor<SDRecipe>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.createdAt, order: .forward)]
            )
            descriptor.fetchLimit = pageSize
            descriptor.fetchOffset = startIndex

            return try context.fetch(descriptor).map(RecipeModel.init)
        }
    }
    
    func fetchFavorites(startIndex: Int = 0, pageSize: Int = 40) async throws -> [RecipeModel] {
        try await dataStore.performBackgroundTask { context in
            let predicate = #Predicate<SDRecipe> { $0.isFavorite }
            var descriptor = FetchDescriptor<SDRecipe>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.createdAt, order: .forward)]
            )
            descriptor.fetchLimit = pageSize
            descriptor.fetchOffset = startIndex

            return try context.fetch(descriptor).map(RecipeModel.init)
        }
    }
    
    func saveRecipes(_ recipes: [RecipeModel]) async throws -> (inserted: [RecipeModel], updated: [RecipeModel]) {
        try await dataStore.performBackgroundTask { context in
            let existing = try self.existingRecipes(ids: recipes.map(\.id), context: context)
            var insertedRecipes: [RecipeModel] = []
            var updatedRecipes: [RecipeModel] = []
            
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
    
    func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool {
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
    
    func existingRecipes(ids: [Int], context: ModelContext) throws -> [Int: SDRecipe] {
        let predicate = #Predicate<SDRecipe> { ids.contains($0.id) }
        let descriptor = FetchDescriptor<SDRecipe>(predicate: predicate)
        return try context.fetch(descriptor).reduce(into: [:]) { $0[$1.id] = $1 }
    }
}

//search
extension RecipeSDRepository {

    func searchRecipes(
        query: String,
        startIndex: Int,
        pageSize: Int
    ) async throws -> [RecipeModel] {

        let normalized = normalize(query)

        return try await dataStore.performBackgroundTask { [self] context in
            guard !normalized.isEmpty else {
                return try fetchAllRecipes(
                    startIndex: startIndex,
                    pageSize: pageSize,
                    context: context
                )
            }

            let predicate = #Predicate<SDRecipe> { recipe in
                recipe.name.localizedStandardContains(normalized)
            }

            return try executeSearch(
                predicate: predicate,
                startIndex: startIndex,
                pageSize: pageSize,
                context: context
            )
        }
    }

    //trims + collapses internal whitespace.
    private func normalize(_ raw: String) -> String {
        raw.trimmingCharacters(in: .whitespacesAndNewlines)
           .components(separatedBy: .whitespacesAndNewlines)
           .filter { !$0.isEmpty }
           .joined(separator: " ")
    }

    private func fetchAllRecipes(
        startIndex: Int,
        pageSize: Int,
        context: ModelContext
    ) throws -> [RecipeModel] {
        var descriptor = FetchDescriptor<SDRecipe>(
            sortBy: [
                SortDescriptor(\.name, order: .forward),
                SortDescriptor(\.createdAt, order: .forward)
            ]
        )
        descriptor.fetchLimit  = pageSize
        descriptor.fetchOffset = startIndex

        return try context.fetch(descriptor).map(RecipeModel.init)
    }

    private func executeSearch(
        predicate: Predicate<SDRecipe>,
        startIndex: Int,
        pageSize: Int,
        context: ModelContext
    ) throws -> [RecipeModel] {
        var descriptor = FetchDescriptor<SDRecipe>(
            predicate: predicate,
            sortBy: [
                SortDescriptor(\.name, order: .forward),
                SortDescriptor(\.createdAt, order: .forward)
            ]
        )
        descriptor.fetchLimit  = pageSize
        descriptor.fetchOffset = startIndex

        return try context.fetch(descriptor).map(RecipeModel.init)
    }
}

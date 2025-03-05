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
    case modelNotFound
    case modelObjNotFound
}

@MainActor
public final class RecipeSDRepository: RecipeSDRepositoryType {
    private let context: ModelContext
    
    public init(context: ModelContext) {
        self.context = context
    }
    
    //later add batch fetch rather than bulk fetching
    public func fetchRecipes() async throws -> [RecipeDomain] {
        let descriptor = FetchDescriptor<SDRecipe>()
        let objs = try context.fetch(descriptor)
        print("**** fetch cound: \(objs.count)")
        return try context.fetch(descriptor).map { RecipeDomain(from: $0) }
    }
    
    public func saveRecipes(_ recipes: [RecipeDomain]) async throws {
        let existingRecipesDic = try self.existingRecipes(ids: recipes.map(\.id), context: context)
        
        for domainRecipe in recipes {
            if let existingRecipes = existingRecipesDic[domainRecipe.id] {
                existingRecipes.update(from: domainRecipe)
            } else {
                let newRecipe = SDRecipe(from: domainRecipe)
                context.insert(newRecipe)
            }
        }
        
        try context.save()
    }

    public func updateFavouriteRecipe(_ recipeID: Int) async throws -> Bool {
        let predicate = #Predicate<SDRecipe> { $0.id == recipeID }
        let descriptor = FetchDescriptor<SDRecipe>(predicate: predicate)
        
        guard let existingRecipe = try context.fetch(descriptor).first else {
            throw SDError.modelObjNotFound
        }
        
        existingRecipe.isFavorite.toggle()
        
        try context.save()
        
        return existingRecipe.isFavorite
    }
        
    private func existingRecipes(ids: [Int], context: ModelContext) throws -> [Int: SDRecipe] {
        let predicate = #Predicate<SDRecipe> { ids.contains($0.id) }
        let descriptor = FetchDescriptor<SDRecipe>(predicate: predicate)
        return try context.fetch(descriptor).reduce(into: [:]) { $0[$1.id] = $1 }
    }
}

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
    
#warning("fetch with page count, first 50")
    public func fetchRecipes() async throws -> [RecipeDomain] {
        let descriptor = FetchDescriptor<SDRecipe>()
        let objs = try context.fetch(descriptor)
        print("**** fetch cound: \(objs.count)")
        return try context.fetch(descriptor).map { RecipeDomain(from: $0) }
    }
    
    public func saveRecipes(_ recipes: [RecipeDomain]) async throws {
        
        print(recipes.count)
        print(recipes.first?.name)
        
//        print("**** recipes.count: \(recipes.count)")
//        let ids = recipes.map { $0.id }
//        
//        let predicate = #Predicate<SDRecipe> { ids.contains($0.id ?? 0) }
//        let descriptor = FetchDescriptor<SDRecipe>(predicate: predicate)
//        let existingRecipes = try context.fetch(descriptor)
//        var existingDict: [String: SDRecipe] = [:]
//        for recipe in existingRecipes {
//            existingDict[recipe.id] = recipe
//        }
//        
//        for domainRecipe in recipes {
//            if let existingRecipes = existingDict[domainRecipe.id] {
//                existingRecipes.update(from: domainRecipe)
//            } else {
//                let newRecipe = SDRecipe(from: domainRecipe)
//                context.insert(newRecipe)
//            }
//        }
//        
//        try context.save()
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
}

/*
 @Model
 final class Recipe {
     @Attribute(.unique) let id: Int
     var name: String
     var countryCode: String  // Store raw value
     
     // Transient property for business logic (not persisted)
     @Transient
     var country: Country {
         Country(code: countryCode)
     }

     init(id: Int, name: String, countryCode: String) {
         self.id = id
         self.name = name
         self.countryCode = countryCode
     }
 }
 
 // Network DTO
 struct RecipeDTO: Codable {
     let id: Int
     let name: String
     let country: String  // Raw API value
     
     func toPersistable() -> Recipe {
         Recipe(
             id: id,
             name: name,
             countryCode: country
         )
     }
 }

 // Country Type Handler
 struct Country {
     let code: String
     var knownCase: KnownCountry?
     
     enum KnownCountry: String, CaseIterable {
         case us = "US"
         case gb = "GB"
         case ca = "CA"
         // Add others
     }
     
     init(code: String) {
         self.code = code.uppercased()
         self.knownCase = KnownCountry(rawValue: code.uppercased())
     }
 }
 
 // Fetching with type safety
 let usRecipes = try context.fetch(FetchDescriptor<Recipe>(
     predicate: #Predicate { $0.countryCode == "US" }
 ))

 // Business logic handling
 func displayCountry(for recipe: Recipe) -> String {
     switch recipe.country.knownCase {
     case .us: return "United States"
     case .gb: return "United Kingdom"
     case .ca: return "Canada"
     case nil: return "Other (\(recipe.countryCode))"
     }
 }
 
*/

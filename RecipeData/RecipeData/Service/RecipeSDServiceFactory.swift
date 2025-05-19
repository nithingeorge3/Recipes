//
//  RecipeRepository.swift
//  RecipeData
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation
import RecipeDomain
import SwiftData

public protocol RecipeSDServiceFactoryType {
    func makeRecipeSDService(container: ModelContainer) -> RecipeSDServiceType
}

public final class RecipeSDServiceFactory: RecipeSDServiceFactoryType {
    public init() { }
    
    public func makeRecipeSDService(container: ModelContainer) -> RecipeSDServiceType {
        let repository = RecipeSDRepository(container: container)
        return RecipeSDService(repository: repository)
    }
}

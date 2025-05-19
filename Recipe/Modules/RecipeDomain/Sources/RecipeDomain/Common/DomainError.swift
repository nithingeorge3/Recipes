//
//  Error.swift
//  RecipeDomain
//
//  Created by Nitin George on 07/03/2025.
//

import Foundation

@frozen
public enum RecipeError: Error, Equatable {
    case notFound(recipeID: Int)
    
    public static func == (lhs: RecipeError, rhs: RecipeError) -> Bool {
        switch (lhs, rhs) {
        case (.notFound, .notFound):
            return true
        }
    }
}

extension RecipeError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notFound(let id):
            return "Recipe with ID \(id) not found."
        }
    }
}

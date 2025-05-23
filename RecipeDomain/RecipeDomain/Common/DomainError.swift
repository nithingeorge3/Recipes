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
    case searchFailed(String)
    case fetchFailed(String)
    
    public static func == (lhs: RecipeError, rhs: RecipeError) -> Bool {
        switch (lhs, rhs) {
        case (.notFound(let lhsID), .notFound(let rhsID)):
            return lhsID == rhsID
        case (.searchFailed(let lhsMsg), .searchFailed(let rhsMsg)):
            return lhsMsg == rhsMsg
        case (.fetchFailed(let lhsMsg), .fetchFailed(let rhsMsg)):
            return lhsMsg == rhsMsg
        default:
            return false
        }
    }
}

extension RecipeError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notFound(let id):
            return "Recipe with ID \(id) not found."
        case .searchFailed(let reason):
            return "Search failed: \(reason)."
        case .fetchFailed(let reason):
            return "fetch failed: \(reason)."
        }
    }
}

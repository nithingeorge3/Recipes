//
//  AppConfiguration.swift
//  RecipeCore
//
//  Created by Nitin George on 21/05/2025.
//

import Foundation

public protocol AppConfigurableRecipeType {
    var recipeBaseURL: String { get }
    var recipeEndPoint: String { get }
}

public struct AppConfiguration: AppConfigurableRecipeType {
    private enum ConfigurationKey: String {
        case recipeBaseURL = "RECIPE_BASE_URL"
        case recipeEndPoint = "RECIPE_END_POINT"
    }
    
    private let infoDictionary: [String: Any]
    
    public init() {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        self.infoDictionary = dict
    }
    
    private func value(for key: ConfigurationKey) -> String {
        guard let value = infoDictionary[key.rawValue] as? String else {
            fatalError("\(key.rawValue) not set in plist for this environment")
        }
        return value
    }
    
    public var recipeBaseURL: String {
        value(for: .recipeBaseURL)
//        guard let url = URL(string: value(for: .recipeBaseURL)) else {
//            fatalError("Recipe Base URL is invalid")
//        }
//        return url
    }
    
    public var recipeEndPoint: String {
        value(for: .recipeEndPoint)
    }
}

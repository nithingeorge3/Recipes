//
//  Constants.swift
//  Recipes
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation

enum Constants {
    enum Recipe {
        static let listSpacing: CGFloat = 4
        static let listItemSize: CGFloat = 120
        static let fetchLimit: Int = 40
        static let maxAllowedRecipes: Int = 400 // Handle bulk download logic
        static let fetchImagesLimit: Int = 4
        static let placeholderImage = "recipePlaceholder"
    }
}

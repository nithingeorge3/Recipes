//
//  RecipeView.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI

struct RecipeGridImageView: View {
    let recipe: Recipe
    let gridSize: CGFloat
    
    var body: some View {
        VStack {
            recipeImage
            recipeName
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to view recipe details")
        .accessibilityAddTraits(.isButton)
    }
    
    private var recipeImage: some View {
        Group {
            if let url = recipe.thumbnailURL.validatedURL {
                RecipeImageView(imageURL: url, width: gridSize, height: gridSize)
            } else {
                Image(Constants.Recipe.placeholderImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: gridSize, height: gridSize)
                    .accessibilityHidden(true)
            }
        }
        .cornerRadius(10)
        .accessibilityHidden(true)
    }
    
    private var recipeName: some View {
        Text(recipe.name)
            .font(.system(size: 14, weight: .semibold))
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.75)
            .dynamicTypeSize(...DynamicTypeSize.accessibility2)
    }
    
    private var accessibilityLabel: String {
        var label = recipe.name
        if recipe.isFavorite {
            label += ", Favorite"
        }
        
        label += ", From \(recipe.country.displayName)"
        
        return label
    }
}

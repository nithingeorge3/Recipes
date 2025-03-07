//
//  RecipeGridView.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI

struct RecipesGridView: View {
    var favorites: [Recipe]
    var others: [Recipe]
    var hasMoreData: Bool
    var onRecipeTap: (Recipe) -> Void
    var onReachBottom: () -> Void
    
    @State private var isFavoritesCollapsed: Bool = false
    @State private var isOtherCollapsed: Bool = false
    @State private var showProgress: Bool = false
    
    var body: some View {
        return GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let spacing: CGFloat = Constants.Recipe.listSpacing
            let minColumnWidth = Constants.Recipe.listItemSize
            let columns = calculateColumns(totalWidth: totalWidth, spacing: spacing, minColumnWidth: minColumnWidth)
            let coulmnsCount = max(columns.count, 1)
            let padding = Constants.Recipe.listSpacing * CGFloat(coulmnsCount - 1) / 2.0 + 32.0
            let gridSize = max((totalWidth - padding)/CGFloat(coulmnsCount), Constants.Recipe.listItemSize)
            
            ScrollView {
                LazyVGrid(columns: columns) {
                    if !favorites.isEmpty {
                        CollapsibleSection(title: "Favourites", isCollapsed: $isFavoritesCollapsed) {
                            recipeGrid(for: favorites, size: gridSize)
                        }
                    }

                    if !favorites.isEmpty {
                        CollapsibleSection(title: "Other Recipes", isCollapsed: $isOtherCollapsed) {
                            recipeGrid(for: others, size: gridSize)
                        }
                    } else {
                        recipeGrid(for: others, size: gridSize)
                    }

                    if !others.isEmpty && hasMoreData {
                        ProgressView()
                            .opacity(showProgress ? 1 : 0)
                            .frame(height: 50, alignment: .center)
                            .onAppear {
                                showProgress = !isOtherCollapsed
                                onReachBottom()
                            }
                            .onDisappear {
                                showProgress = false
                            }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
    
    @ViewBuilder
    private func recipeGrid(for recipes: [Recipe], size: CGFloat) -> some View {
        ForEach(recipes) { recipe in
            RecipeGridImageView(recipe: recipe, gridSize: size)
                .onTapGesture {
                    onRecipeTap(recipe)
                }
        }
    }
}

extension RecipesGridView {
    func calculateColumns(totalWidth: CGFloat, spacing: CGFloat, minColumnWidth: CGFloat) -> [GridItem] {
        let availableWidth = totalWidth - spacing * 2
        let columnsCount = max(availableWidth/(minColumnWidth + spacing), 1)
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: Int(columnsCount))
    }
}

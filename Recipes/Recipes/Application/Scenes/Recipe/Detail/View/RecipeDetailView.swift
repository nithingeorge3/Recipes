//
//  RecipeDetailView.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI
import Kingfisher

struct RecipeDetailView: View {
    @Bindable var viewModel: RecipeDetailViewModel //ToDo: use depency inversion later
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        Group {
            contentView(for: viewModel.recipe)
                .withCustomNavigationTitle(title: viewModel.recipe.name)
//            if let recipe = viewModel.recipe {
//                contentView(for: viewModel.recipe)
//                    .withCustomNavigationTitle(title: viewModel.recipe.name)
//            } else {
//                EmptyStateView(message: "No recipe detail found. Please try again later.")
//            }
        }
//        .onAppear() {
//            if viewModel.recipe == nil {
//                viewModel.send(.loadRecipe)
//            }
//        }
        .withCustomBackButton()
    }
    
    @ViewBuilder
    private func contentView(for recipe: Recipe) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    if let image = recipe.thumbnailURL {
                        RecipeImageCarousel(image: image, selectedIndex: $selectedIndex)
                    } else {
                        Image(Constants.placeHolderImage)
                            .resizable()
                            .cornerRadius(25)
                            .padding(.horizontal, 8)
                    }
                }
                .frame(height: 400)
                .padding(.bottom, 4)

                // adding more Recipe details
                nameCountrySection(for: recipe)
                detailSection(for: recipe)
            }
        }
    }
    
    @ViewBuilder
    private func nameCountrySection(for recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(recipe.name)
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    viewModel.send(.toggleFavorite)
                }) {
                    Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 28))
                        .foregroundColor(recipe.isFavorite ? .red : .gray)
                        .symbolEffect(.bounce, value: recipe.isFavorite)
                }
                
                Spacer().frame(width: 30)
            }
            
//            if let origin = recipe.country {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                    Text("origin")
                }
                .font(.title3)
                .foregroundColor(.secondary)
//            }
        }
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder
    private func detailSection(for recipe: Recipe) -> some View {
        Group {
            SubTitleView(title: "Description")
            
            Text(recipe.description ?? "No description avilable")
                .font(.body)
                .lineSpacing(6)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .padding(.horizontal, 8)
    }
}

struct SubTitleView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.semibold)
    }
}

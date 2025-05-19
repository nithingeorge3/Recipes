//
//  RecipeDetailView.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI
import Kingfisher
import RecipeDomain
import RecipeNetworking

import RecipeUI

struct RecipeDetailView<ViewModel: RecipeDetailViewModelType>: View {
    @Bindable var viewModel: ViewModel
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @State private var selectedIndex: Int = 0
    @State private var showFavouriteConfirmation: Bool = false
    @State private var favTask: Task<Void, Never>?
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()                
            case .loaded(let recipe):
                contentView(for: recipe)
                
            case .error(let error):
                ErrorView(error: error) {
                    Task {
                        await viewModel.send(.loadRecipe)
                    }
                }
            }
        }
        .onAppear {
            tabBarVisibility.isHidden = true
        }
        .task {
            await viewModel.send(.loadRecipe)
        }
        .alert("Remove from saved", isPresented: $showFavouriteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                favTask?.cancel()
                favTask = Task {
                    await viewModel.send(.toggleFavorite)
                }
            }
        } message: {
            Text("The Recipe will be removed from your saved list.")
        }
        .withCustomBackButton()
        .withCustomNavigationTitle(title: viewModel.navigationTitle)
    }
    
    @ViewBuilder
    private func contentView(for recipe: Recipe) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                RecipeImageCarouselView(
                    mediaItems: viewModel.mediaItems,
                    selectedIndex: $selectedIndex
                )
                .frame(height: 400)
                .padding(.bottom, 4)
                
                nameCountrySection(for: recipe)
                detailSection(for: recipe)
            }
        }
        .scrollIndicators(.hidden)
    }
    
    @ViewBuilder
    private func nameCountrySection(for recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(recipe.name)
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                VStack(alignment: .center) {
                    Spacer().frame(height: 10.0)
                    Button(action: {
                        if viewModel.favouriteStatus() {
                            showFavouriteConfirmation = true
                        }
                        else {
                            Task {
                                await viewModel.send(.toggleFavorite)
                            }
                        }
                    }) {
                        Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 28))
                            .foregroundColor(recipe.isFavorite ? .red : .gray)
                            .symbolEffect(.bounce, value: recipe.isFavorite)
                    }
                    Spacer()
                }
                
                Spacer().frame(width: 30)
            }
            
            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse")
                Text(recipe.country.displayName)
            }
            .font(.title3)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder
    private func detailSection(for recipe: Recipe) -> some View {
        Group {
            RecipeMetaInfoView(createdAt: viewModel.createdAtString, servings: recipe.yields)
            SubTitleView(title: "Description")
            DescriptionText(description: recipe.description)
            RatingsSectionView(ratings: recipe.ratings)
        }
        .padding(.horizontal, 8)
    }
    
    private struct DescriptionText: View {
        let description: String?
        
        var body: some View {
            Group {
                if let description = description, !description.isEmpty {
                    Text(description)
                        .descriptionStyle()
                } else {
                    DescriptionEmptyState()
                }
            }
            .transition(.opacity)
        }
    }
    
    private struct DescriptionEmptyState: View {
        var body: some View {
            HStack(spacing: 8) {
                Image(systemName: "text.bubble")
                    .foregroundColor(.secondary)
                
                Text("Description unavailable")
                    .foregroundColor(.secondary.opacity(0.8))
            }
            .font(.subheadline)
            .accessibilityElement(children: .combine)
        }
    }
}

private extension Text {
    func descriptionStyle() -> some View {
        self
            .font(.body)
            .lineSpacing(6)
            .foregroundColor(.primary.opacity(0.9))
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(nil)
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

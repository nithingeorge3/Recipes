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

struct RecipeDetailView<ViewModel: RecipeDetailViewModelType>: View {
    @Bindable var viewModel: ViewModel
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

// MARK: - Previews
#if DEBUG
#Preview("Default Detail") {
    RecipeDetailView(viewModel: PreviewDetailViewModel.fullRecipe)
}

#Preview("No Image") {
    RecipeDetailView(viewModel: PreviewDetailViewModel.noImageRecipe)
}

#Preview("No Description") {
    RecipeDetailView(viewModel: PreviewDetailViewModel.noDescriptionRecipe)
}

#Preview("Favorite State") {
    let vm = PreviewDetailViewModel.fullRecipe
    vm.recipe.isFavorite.toggle()
    return RecipeDetailView(viewModel: vm)
}

// MARK: - Preview ViewModel
private class PreviewDetailViewModel: RecipeDetailViewModelType {
    var recipe: Recipe
    private let service: MockPreviewService
    
    init(recipe: Recipe, service: MockPreviewService = MockPreviewService()) {
        self.recipe = recipe
        self.service = service
    }
    
    func send(_ action: RecipeDetailActions) {
        switch action {
        case .toggleFavorite:
            recipe.isFavorite.toggle()
            Task { try? await service.updateFavouriteRecipe(recipe.id ?? 0) }
        }
    }
}

extension PreviewDetailViewModel {
    static var fullRecipe: PreviewDetailViewModel {
        PreviewDetailViewModel(recipe: Recipe(
            id: 1,
            name: "Indian Chicken Curry",
            description: "Indian Chicken Curry is a rich, flavorful dish made with tender chicken simmered in a spiced tomato and onion gravy. It’s infused with aromatic Indian spices, garlic, ginger, and creamy textures, making it perfect to pair with rice or naan bread.",
            thumbnailURL: "https://img.buzzfeed.com/thumbnailer-prod-us-east-1/45b4efeb5d2c4d29970344ae165615ab/FixedFBFinal.jpg"
        ))
    }
    
    static var noImageRecipe: PreviewDetailViewModel {
        PreviewDetailViewModel(recipe: Recipe(
            id: 2,
            name: "Kerala Chicken Biriyani (CB)",
            description: "A flavorful one-pot dish made with fragrant basmati rice, marinated chicken, and aromatic Kerala spices, layered and cooked to perfection. Side dish: Fresh yummy salad",
            thumbnailURL: nil
        ))
    }
    
    static var noDescriptionRecipe: PreviewDetailViewModel {
        PreviewDetailViewModel(recipe: Recipe(
            id: 3,
            name: "Kerala Chicken Curry",
            description: "", //Handle UI if no description available. Now jsut showing Title
            thumbnailURL: "https://img.buzzfeed.com/thumbnailer-prod-us-east-1/45b4efeb5d2c4d29970344ae165615ab/FixedFBFinal.jpg"
        ))
    }
}

// MARK: - Mock Service
private class MockPreviewService: RecipeServiceType, @unchecked Sendable {
    func updateFavouriteRecipe(_ id: Int) async throws -> Bool {
        return true
    }
    
    var favoritesDidChange: AsyncStream<Int> {
        AsyncStream { _ in }
    }
    
    func fetchRecipes(endPoint: EndPoint) async throws -> [RecipeDomain] {
        return []
    }
}
#endif

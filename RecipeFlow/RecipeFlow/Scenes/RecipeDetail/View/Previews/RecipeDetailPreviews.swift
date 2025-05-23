//
//  RecipeDetailPreviews.swift
//  Recipes
//
//  Created by Nitin George on 24/03/2025.
//

import SwiftUI
import RecipeDomain
import RecipeNetworking
import RecipeUI
import RecipeCore
import Combine

#if DEBUG
#Preview("Default Detail") {
    RecipeDetailView(viewModel: PreviewDetailViewModel.fullRecipe)
        .environmentObject(TabBarVisibility())
}

#Preview("No Image") {
    RecipeDetailView(viewModel: PreviewDetailViewModel.noImageRecipe)
        .environmentObject(TabBarVisibility())
}

#Preview("No Description") {
    RecipeDetailView(viewModel: PreviewDetailViewModel.noDescriptionRecipe)
        .environmentObject(TabBarVisibility())
}

#Preview("Favorite State") {
    let vm = PreviewDetailViewModel.fullFavRecipe
    return RecipeDetailView(viewModel: vm)
            .environmentObject(TabBarVisibility())
}

// MARK: - Preview ViewModel
public class PreviewDetailViewModel: RecipeDetailViewModelType {
    var navigationTitle: String = ""
    var createdAtString: String? = "28/03/2023"
    var state: RecipeDetailState = .loading
    
    var recipe: Recipe?
    var showFavouriteConfirmation: Bool = false
    private let recipeID: Recipe.ID
    private let service: RecipeLocalServiceType
    
    var mediaItems: [PresentedMedia] {
        var result: [PresentedMedia] = []
        if let imageURL = recipe?.thumbnailURL.validatedURL {
            result.append(.image(imageURL))
        }
        if let videoURL = recipe?.originalVideoURL.validatedURL {
            result.append(.video(videoURL))
        }
        
        return result
    }
    
    @MainActor
    init(recipe: Recipe) {
        self.recipe = recipe
        self.recipeID = recipe.id
        self.service = MockPreviewService()
        
        self.state = .loaded(recipe)
    }
    
    @MainActor
    init(recipeID: Recipe.ID, service: RecipeLocalServiceType = MockPreviewService()) {
        self.recipeID = recipeID
        self.service = service
    }
    
    func send(_ action: RecipeDetailActions) async {
        switch action {
        case .toggleFavorite:
            recipe?.isFavorite.toggle()
            Task { try? await service.updateFavouriteRecipe(recipeID) }
        case .loadRecipe:
            let dummyRecipe = Recipe(id: 1, name: "Pasta", ratings: UserRatings(id: 1))
            state = .loaded(recipe ?? dummyRecipe)
        }
    }
    
    func favouriteStatus() -> Bool {
        switch state {
        case .loaded(let recipe):
            return recipe.isFavorite
        default:
            return false
        }
    }
}

extension PreviewDetailViewModel {
    static var fullRecipe: PreviewDetailViewModel {
        PreviewDetailViewModel(
            recipe: Recipe(
                id: 1,
                name: "Indian Chicken Curry",
                description: "Indian Chicken Curry is a rich, flavorful dish made with tender chicken simmered in a spiced tomato and onion gravy. It’s infused with aromatic Indian spices, garlic, ginger, and creamy textures, making it perfect to pair with rice or naan bread.",
                country: .ind,
                thumbnailURL: "https://img.buzzfeed.com/thumbnailer-prod-us-east-1/45b4efeb5d2c4d29970344ae165615ab/FixedFBFinal.jpg",
                originalVideoURL: "https://s3.amazonaws.com/video-api-prod/assets/a0e1b07dc71c4ac6b378f24493ae2d85/FixedFBFinal.mp4",
                yields: "Serve 4",
                isFavorite: false,
                ratings: UserRatings(id: 1, countNegative: 169, countPositive: 3525, score: 0.95)
            )
        )
    }
    
    static var fullFavRecipe: PreviewDetailViewModel {
        PreviewDetailViewModel(
            recipe: Recipe(
                id: 1,
                name: "Indian Chicken Curry",
                description: "Indian Chicken Curry is a rich, flavorful dish made with tender chicken simmered in a spiced tomato and onion gravy. It’s infused with aromatic Indian spices, garlic, ginger, and creamy textures, making it perfect to pair with rice or naan bread.",
                country: .ind,
                thumbnailURL: "https://img.buzzfeed.com/thumbnailer-prod-us-east-1/45b4efeb5d2c4d29970344ae165615ab/FixedFBFinal.jpg",
                originalVideoURL: "https://s3.amazonaws.com/video-api-prod/assets/a0e1b07dc71c4ac6b378f24493ae2d85/FixedFBFinal.mp4",
                yields: "Serve 4",
                isFavorite: true,
                ratings: UserRatings(id: 1, countNegative: 169, countPositive: 3525, score: 0.95)
            )
        )
    }
    
    static var noImageRecipe: PreviewDetailViewModel {
        PreviewDetailViewModel(recipe: Recipe(
            id: 2,
            name: "Kerala Chicken Biriyani (CB)",
            description: "A flavorful one-pot dish made with fragrant basmati rice, marinated chicken, and aromatic Kerala spices, layered and cooked to perfection. Side dish: Fresh yummy salad",
            country: .ind,
            thumbnailURL: nil,
            ratings: UserRatings(id: 2)
        ))
    }
    
    static var noDescriptionRecipe: PreviewDetailViewModel {
        PreviewDetailViewModel(recipe: Recipe(
            id: 3,
            name: "Kerala Chicken Curry",
            description: "",
            country: .ind,
            thumbnailURL: "https://img.buzzfeed.com/thumbnailer-prod-us-east-1/45b4efeb5d2c4d29970344ae165615ab/FixedFBFinal.jpg",
            ratings: UserRatings(id: 3)
        ))
    }
}

// MARK: - Mock Service
private class MockPreviewService: RecipeLocalServiceType, @unchecked Sendable {
    var favoriteDidChange: AnyPublisher<Int, Never> = Empty().eraseToAnyPublisher()
    
    func fetchRecipesCount() async throws -> Int {
        0
    }
    
    func fetchFavoritesRecipesCount() async throws -> Int {
        0
    }
    
    func fetchRecipe(for recipeID: Int) async throws -> RecipeModel {
        RecipeModel(id: 999, name: "Mock Recipe")
    }
    
    func fetchRecipes(startIndex: Int, pageSize: Int) async throws -> [RecipeModel] {
        []
    }
    
    func fetchFavorites(startIndex: Int, pageSize: Int) async throws -> [RecipeModel] {
        []
    }
    
    func fetchPagination(_ type: EntityType) async throws -> PaginationDomain {
        PaginationDomain(entityType: .recipe, totalCount: 10, currentPage: 10)
    }
    
    func fetchRecipe(id: Recipe.ID) async throws -> Recipe {
        Recipe(id: 999, name: "Mock Recipe", ratings: UserRatings(id: 1))
    }
    
    func updateFavouriteRecipe(_ id: Int) async throws -> Bool {
        true
    }
    
    func searchRecipes(query: String, startIndex: Int, pageSize: Int) async throws -> [RecipeModel] {
        []
    }
}
#endif

//
//  RecipeDetailViewModel.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Foundation
import RecipeDomain
import RecipeNetworking
import Observation
import RecipeCore

enum RecipeDetailState: Equatable {
    case loading
    case loaded(Recipe)
    case error(RecipeError)
    
    static func == (lhs: RecipeDetailState, rhs: RecipeDetailState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case let (.loaded(l), (.loaded(r))):
            return l.id == r.id
        case let (.error(l), .error(r)):
            return l == r
        default:
            return false
        }
    }
}

enum PresentedMedia: Identifiable {
    case image(URL)
    case video(URL)
    
    var id: String {
        switch self {
        case .image(let url): return "\(url.absoluteString)"
        case .video(let url): return "\(url.absoluteString)"
        }
    }
}

@MainActor
protocol RecipeDetailViewModelType: AnyObject, Observable {
    var state: RecipeDetailState { get }
    var navigationTitle: String  { get }
    var createdAtString: String? { get }
    var mediaItems: [PresentedMedia] { get }
    var showFavouriteConfirmation: Bool { get set }
    
    func send(_ action: RecipeDetailActions) async
    func favouriteStatus() -> Bool
}

@Observable
class RecipeDetailViewModel: RecipeDetailViewModelType {    
    var showFavouriteConfirmation = false
    var navigationTitle = ""
    var createdAtString: String?
    
    private let recipeID: Recipe.ID
    private let service: RecipeLocalServiceType
        
    var mediaItems: [PresentedMedia] {
        guard case let .loaded(recipe) = state else { return [] }
        return createMediaItems(for: recipe)
    }
    
     var state: RecipeDetailState = .loading {
         didSet {
             updateNavigationTitle()
         }
    }
        
    private func updateNavigationTitle() {
        switch state {
        case .loaded(let recipe):
            navigationTitle = recipe.name
        case .loading, .error:
            navigationTitle = "Recipe Details"
        }
    }
    
    init(recipeID: Recipe.ID, service: RecipeLocalServiceType) {
        self.service = service
        self.recipeID = recipeID
    }
    
    func send(_ action: RecipeDetailActions) async {
        switch action {
        case .loadRecipe:
            await fetchRecipe()
        case .toggleFavorite:
            await handleFavoriteToggle()
        }
    }
    
    func favouriteStatus() -> Bool {
        switch state {
        case .loaded(let recipe):
            recipe.isFavorite
        default:
            false
        }
    }
}

private extension RecipeDetailViewModel {
    private func fetchRecipe() async {
        do {
            let recipeDomain = try await service.fetchRecipe(for: recipeID)
            let recipe = Recipe(from: recipeDomain)
            state = .loaded(recipe)
            createdAtString = DateFormatter.relativeDateString(
                from: recipe.createdAt
            )
        } catch {
            state = .error(RecipeError.notFound(recipeID: recipeID))
        }
    }
    
    private func handleFavoriteToggle() async {
        guard case var .loaded(recipe) = state else { return }
                
        recipe.isFavorite.toggle()
        let updatedValue = recipe.isFavorite
        do {
            let success = try await service.updateFavouriteRecipe(recipeID)
            recipe.isFavorite = success
            state = .loaded(recipe)
        } catch {
            state = .error(RecipeError.notFound(recipeID: recipeID))
            recipe.isFavorite = !updatedValue
        }
    }
    
    func createMediaItems(for recipe: Recipe) -> [PresentedMedia] {
        var items: [PresentedMedia] = []
        
        if let imageURL = recipe.thumbnailURL.validatedURL {
            items.append(.image(imageURL))
        }
        
        if let videoURL = recipe.originalVideoURL.validatedURL {
            items.append(.video(videoURL))
        }
        
        return items
    }
}

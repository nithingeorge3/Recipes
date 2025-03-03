//
//  RecipeDetailViewModel.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Foundation
import RecipeNetworking
import Observation

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
    var recipe: Recipe { get set }
    var mediaItems: [PresentedMedia] { get }
    
    func send(_ action: RecipeDetailActions)
}

@Observable
class RecipeDetailViewModel: RecipeDetailViewModelType {    
    var recipe: Recipe
    
    var mediaItems: [PresentedMedia] {
        var result: [PresentedMedia] = []
        if let imageURL = recipe.thumbnailURL.validatedURL {
            result.append(.image(imageURL))
        }
        if let videoURL = recipe.originalVideoURL.validatedURL {
            result.append(.video(videoURL))
        }
        
        return result
    }
    
    private let service: RecipeServiceType
    
    // I have injected service here in case we need to fetch more images or any backend API update (update toggleFavorite to backend). In this case we don't need but i have added for future functionality
    init(recipe: Recipe, service: RecipeServiceType) {
        self.recipe = recipe
        self.service = service
    }
    
    func send(_ action: RecipeDetailActions) {
        switch action {
        case .toggleFavorite:
            recipe.isFavorite.toggle()
            Task {
                do {
                    if let id = recipe.id {
                        recipe.isFavorite = try await service.updateFavouriteRecipe(id)
                    } else { return }
                } catch {
                    print("failed to upadte SwiftData: errro \(error)")
                }
            }
        }
    }
}

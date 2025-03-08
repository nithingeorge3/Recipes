//
//  RecipeDetailCoordinator.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI
import RecipeNetworking
import RecipeDataStore
import SwiftData
import RecipeDomain

enum RecipeDetailActions {
    case toggleFavorite
    case load
}

final class RecipeDetailCoordinator: Coordinator {
    private let viewModelFactory: RecipeDetailViewModelFactoryType
    private let viewFactory: RecipeDetailViewFactoryType
    private var viewModel: RecipeDetailViewModel
    private let recipeID: Recipe.ID
    private let service: RecipeSDServiceType
    
    init(
        viewModelFactory: RecipeDetailViewModelFactoryType,
        viewFactory: RecipeDetailViewFactoryType,
        recipeID: Recipe.ID,
        service: RecipeSDServiceType
    ) {
        self.viewModelFactory = viewModelFactory
        self.viewFactory = viewFactory
        self.recipeID = recipeID
        self.service = service
        self.viewModel = viewModelFactory.makeRecipeDetailViewModel(recipeID: recipeID, service: service)
    }
    
    func start() -> some View {
        viewFactory.makeRecipeDetailView(viewModel: viewModel)
    }
}

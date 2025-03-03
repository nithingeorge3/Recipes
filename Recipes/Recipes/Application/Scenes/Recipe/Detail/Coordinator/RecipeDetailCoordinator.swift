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
}

final class RecipeDetailCoordinator: Coordinator {
    private let viewModelFactory: RecipeDetailViewModelFactoryType
    private let viewFactory: RecipeDetailViewFactoryType
    private var viewModel: RecipeDetailViewModel
    private let recipe: Recipe
    private let service: RecipeServiceType
    
    init(
        viewModelFactory: RecipeDetailViewModelFactoryType,
        viewFactory: RecipeDetailViewFactoryType,
        recipe: Recipe,
        service: RecipeServiceType
    ) {
        self.viewModelFactory = viewModelFactory
        self.viewFactory = viewFactory
        self.recipe = recipe
        self.service = service
        self.viewModel = viewModelFactory.makeRecipeDetailViewModel(recipe: recipe, service: service)
    }
    
    func start() -> some View {
        viewFactory.makeRecipeDetailView(viewModel: viewModel)
    }
}

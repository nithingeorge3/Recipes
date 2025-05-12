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
import RecipeUI

enum RecipeDetailActions {
    case loadRecipe
    case toggleFavorite
}

final class RecipeDetailCoordinator: Coordinator {
    private let tabBarVisibility: TabBarVisibility
    private let viewModelFactory: RecipeDetailViewModelFactoryType
    private let viewFactory: RecipeDetailViewFactoryType
    private var viewModel: RecipeDetailViewModel
    private let recipeID: Recipe.ID
    private let service: RecipeSDServiceType
    
    init(
        viewModelFactory: RecipeDetailViewModelFactoryType,
        viewFactory: RecipeDetailViewFactoryType,
        recipeID: Recipe.ID,
        service: RecipeSDServiceType,
        tabBarVisibility: TabBarVisibility
    ) {
        self.viewModelFactory = viewModelFactory
        self.viewFactory = viewFactory
        self.recipeID = recipeID
        self.service = service
        self.viewModel = viewModelFactory.makeRecipeDetailViewModel(recipeID: recipeID, service: service)
        self.tabBarVisibility = tabBarVisibility
    }
    
    func start() -> some View {
        viewFactory.makeRecipeDetailView(viewModel: viewModel)
            .environmentObject(tabBarVisibility)
    }
}

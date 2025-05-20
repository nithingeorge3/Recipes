//
//  RecipeFavouritesCoordinatorFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Foundation
import SwiftData
import RecipeData
import RecipeUI

public protocol RecipeFavouritesCoordinatorFactoryType {
    @MainActor func make(container: ModelContainer, tabBarVisibility: TabBarVisibility) async -> RecipeFavouritesCoordinator
}

public final class RecipeFavouritesCoordinatorFactory: RecipeFavouritesCoordinatorFactoryType {
    public init() { }
    
    public func make(container: ModelContainer, tabBarVisibility: TabBarVisibility) async -> RecipeFavouritesCoordinator {
        let tabItem = TabItem(title: "Saved", icon: "heart.fill", badgeCount: 0, color: .black)
        let modelFactory = RecipeFavouritesViewModelFactory()
        let viewFactory = RecipeFavouritesViewFactory()
        
        let paginationSDService = PaginationSDServiceFactory().makePaginationSDService(container: container)
        let recipeSDService = RecipeSDServiceFactory().makeRecipeSDService(container: container)
        
        return await RecipeFavouritesCoordinator(
            tabItem: tabItem,
            tabBarVisibility: tabBarVisibility,
            viewFactory: viewFactory,
            modelFactory: modelFactory,
            paginationSDService: paginationSDService,
            recipeSDService: recipeSDService
        )
    }
}

//
//  RecipeFavouriteCoordinator.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Combine
import RecipeNetworking
import RecipeData
import SwiftData
import SwiftUI
import RecipeDomain
import RecipeCore
import RecipeUI

@MainActor
public final class RecipeFavouritesCoordinator: ObservableObject, Coordinator, TabItemProviderType {
    let viewFactory: RecipeFavouritesViewFactoryType
    private let modelFactory: RecipeFavouritesViewModelFactoryType
    var viewModel: RecipeFavouritesViewModel
    private let _tabItem: TabItem
    let tabBarVisibility: TabBarVisibility
    private let service: RecipeServiceProvider
    private var cancellables: [AnyCancellable] = []
    
    @Published var navigationPath = NavigationPath()
    
//    private let favoritesEventService: FavoritesEventServiceType
    
    public var tabItem: TabItem {
        _tabItem
    }

    init(
        tabItem: TabItem,
        tabBarVisibility: TabBarVisibility,
        viewFactory: RecipeFavouritesViewFactoryType,
        modelFactory: RecipeFavouritesViewModelFactoryType,
        service: RecipeServiceProvider
//        paginationSDService: PaginationSDServiceType,
//        recipeSDService: RecipeSDServiceType,
//        favoritesEventService: FavoritesEventServiceType
    ) async {
        _tabItem = tabItem
        self.tabBarVisibility = tabBarVisibility
        self.viewFactory = viewFactory
        self.modelFactory = modelFactory
//        self.favoritesEventService = favoritesEventService
        
        self.service = service
        
//        RecipeServiceFactory.makeRecipeService(
//            recipeSDService: recipeSDService,
//            paginationSDService: paginationSDService,
//            favoritesEventService: favoritesEventService
//        )
        
        let favoritesPagination: LocalPaginationHandlerType = FavoritesPaginationHandler()
        print(favoritesPagination.hasMoreData)
        self.viewModel = await modelFactory.make(
            service: service,
            favoritesPagination: favoritesPagination
        )

        addSubscriptions()
    }
    
    public func start() -> some View {
        RecipeFavouritesCoordinatorView(coordinator: self)
    }
    
    func addSubscriptions() {
        viewModel.recipeActionSubject
            .sink { [weak self] action in
                guard let self = self else { return }
                switch action {
                case .selectRecipe(let recipeID):
                    self.navigationPath.append(RecipeAction.selectRecipe(recipeID))
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}

extension RecipeFavouritesCoordinator {
    func navigateToRecipeDetail(for recipeID: Recipe.ID) -> some View {
        let detailedCoordinator = RecipeDetailCoordinatorFactory().makeRecipeDetailCoordinator(recipeID: recipeID, service: service, tabBarVisibility: tabBarVisibility)
        return detailedCoordinator.start()
    }
}

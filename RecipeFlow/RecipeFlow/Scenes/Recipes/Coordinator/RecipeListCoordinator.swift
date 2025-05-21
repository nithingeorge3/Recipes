//
//  RecipeListCoordinator.swift
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

enum RecipeAction: Hashable {
    case refresh
    case loadMore
    case selectRecipe(Recipe.ID)
}

@MainActor
public final class RecipeListCoordinator: ObservableObject, Coordinator, TabItemProviderType {
    let viewFactory: RecipesViewFactoryType
    private let modelFactory: RecipesViewModelFactoryType
    var viewModel: RecipeListViewModel
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
        viewFactory: RecipesViewFactoryType,
        modelFactory: RecipesViewModelFactoryType,
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

        let remotePagination: RemotePaginationHandlerType = RemotePaginationHandler()
        let localPagination: LocalPaginationHandlerType = LocalPaginationHandler()
        
        self.viewModel = await modelFactory.makeRecipeListViewModel(
            service: service,
            remotePagination: remotePagination,
            localPagination: localPagination
        )

        addSubscriptions()
    }
    
    public func start() -> some View {
        RecipeListCoordinatorView(coordinator: self)
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

extension RecipeListCoordinator {
    func navigateToRecipeDetail(for recipeID: Recipe.ID) -> some View {
        let detailedCoordinator = RecipeDetailCoordinatorFactory().makeRecipeDetailCoordinator(recipeID: recipeID, service: service, tabBarVisibility: tabBarVisibility)
        return detailedCoordinator.start()
    }
}

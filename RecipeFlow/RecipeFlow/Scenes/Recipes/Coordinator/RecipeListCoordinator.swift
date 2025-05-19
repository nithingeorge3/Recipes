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

enum RecipeListAction: Hashable {
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
    
    public var tabItem: TabItem {
        _tabItem
    }

    init(
        tabItem: TabItem,
        tabBarVisibility: TabBarVisibility,
        viewFactory: RecipesViewFactoryType,
        modelFactory: RecipesViewModelFactoryType,
        paginationSDService: PaginationSDServiceType,
        recipeSDService: RecipeSDServiceType
    ) async {
        _tabItem = tabItem
        self.tabBarVisibility = tabBarVisibility
        self.viewFactory = viewFactory
        self.modelFactory = modelFactory
        self.service = RecipeServiceFactory.makeRecipeService(recipeSDService: recipeSDService, paginationSDService: paginationSDService)
        
        let remotePagination: RemotePaginationHandlerType = RemotePaginationHandler()
        let localPagination: LocalPaginationHandlerType = LocalPaginationHandler()
        let favoritesPagination: LocalPaginationHandlerType = FavoritesPaginationHandler()
        
        self.viewModel = await modelFactory.makeRecipeListViewModel(
            service: service,
            remotePagination: remotePagination,
            localPagination: localPagination,
            favoritesPagination: favoritesPagination
        )

        addSubscriptions()
    }
    
    public func start() -> some View {
        RecipeListCoordinatorView(coordinator: self)
    }
    
    func addSubscriptions() {
        viewModel.recipeListActionSubject
            .sink { [weak self] action in
                guard let self = self else { return }
                switch action {
                case .selectRecipe(let recipeID):
                    self.navigationPath.append(RecipeListAction.selectRecipe(recipeID))
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

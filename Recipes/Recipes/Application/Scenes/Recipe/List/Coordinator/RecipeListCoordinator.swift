//
//  RecipeListCoordinator.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Combine
import RecipeNetworking
import RecipeDataStore
import SwiftData
import SwiftUI
import RecipeDomain
import RecipeDataStore

enum RecipeListAction: Hashable {
    case refresh
    case loadNextPage
    case userSelectedRecipe(Recipe)
}

@MainActor
final class RecipeListCoordinator: ObservableObject, Coordinator, TabItemProviderType {
    let viewFactory: RecipeListViewFactoryType
    private let modelFactory: RecipeListViewModelFactoryType
    var viewModel: RecipeListViewModel
    private let _tabItem: TabItem
    private let service: RecipeServiceProvider
    private var cancellables: [AnyCancellable] = []
    
    @Published var navigationPath = NavigationPath()
    
    var tabItem: TabItem {
        _tabItem
    }
    
    init(
        tabItem: TabItem,
        viewFactory: RecipeListViewFactoryType,
        modelFactory: RecipeListViewModelFactoryType,
        paginationSDRepo: PaginationSDRepositoryType,
        recipeSDRepo: RecipeSDRepositoryType
    ) async {
        _tabItem = tabItem
        self.viewFactory = viewFactory
        self.modelFactory = modelFactory
        self.service = RecipeServiceFactory.makeRecipeService(recipeSDRepo: recipeSDRepo, paginationSDRepo: paginationSDRepo)
        
        let paginationHandler: PaginationHandlerType = PaginationHandler()
        
        let vm = await modelFactory.makeRecipeListViewModel(
            service: service,
            paginationHandler: paginationHandler
        )

        self.viewModel = vm
        addSubscriptions()
    }
    
    func start() -> some View {
        RecipeListCoordinatorView(coordinator: self)
    }
    
    func addSubscriptions() {
        viewModel.recipeListActionSubject
            .sink { [weak self] action in
                guard let self = self else { return }
                switch action {
                case .userSelectedRecipe(let recipe):
                    self.navigationPath.append(RecipeListAction.userSelectedRecipe(recipe))
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}

extension RecipeListCoordinator {
    func navigateToRecipeDetail(for recipe: Recipe) -> some View {
        print(recipe.name)
        let detailedCoordinator = RecipeDetailCoordinatorFactory().makeRecipeDetailCoordinator(recipe: recipe, service: service)
        return detailedCoordinator.start()
    }
}

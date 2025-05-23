//
//  MenuCoordinator.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI
import RecipeNetworking
import RecipeUI

public final class MenuCoordinator: Coordinator, TabItemProviderType {
    private let _tabItem: TabItem
    private var viewFactory: MenuViewFactoryType
    private var modelFactory: MenuViewModelFactoryType
    private var viewModel: MenuViewModel
    
    public var tabItem: TabItem {
        _tabItem
    }
    
    init(
        tabItem: TabItem,
        viewFactory: MenuViewFactoryType,
        modelFactory: MenuViewModelFactoryType
    ) {
        _tabItem = tabItem
        self.viewFactory = viewFactory
        self.modelFactory = modelFactory
        
        let service = RecipeServiceFactory.makeRecipeKeyService()
        viewModel = modelFactory.make(service: service)
    }
    
    public func start() -> some View {
        AnyView(viewFactory.make(viewModel: viewModel))
    }
}

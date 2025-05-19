//
//  MenuCoordinator.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI
import RecipeNetworking
import RecipeUI

final class MenuCoordinator: Coordinator, TabItemProviderType {
    private var menuViewFactory: MenuViewFactoryType
    private let _tabItem: TabItem
    
    var tabItem: TabItem {
        _tabItem
    }
    
    init(menuViewFactory: MenuViewFactoryType, tabItem: TabItem) {
        self.menuViewFactory = menuViewFactory
        _tabItem = tabItem
    }
    
    func start() -> some View {
        let service = RecipeServiceFactory.makeRecipeKeyService()
        return menuViewFactory.makeMenuView(service: service)
    }
}

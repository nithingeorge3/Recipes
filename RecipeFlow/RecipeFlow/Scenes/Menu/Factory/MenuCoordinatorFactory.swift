//
//  MenuCoordinatorFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Foundation

import RecipeUI

@MainActor
public protocol MenuCoordinatorFactoryType {
    func makeMenuCoordinator() -> MenuCoordinator
}

public final class MenuCoordinatorFactory: MenuCoordinatorFactoryType {
    public init() { }
    
    public func makeMenuCoordinator() -> MenuCoordinator {
        let tabItem = TabItem(title: "Menu", icon: "line.horizontal.3", badgeCount: nil, color: .black)
        
        let modelFactory = MenuViewModelFactory()
        let viewFactory = MenuViewFactory()
        
        return MenuCoordinator(
            tabItem: tabItem,
            viewFactory: viewFactory,
            modelFactory: modelFactory
        )
    }
}

//
//  MenuViewModelFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import RecipeNetworking

protocol MenuViewModelFactoryType {
    func make(service: RecipeKeyServiceType) -> MenuViewModel
}

final class MenuViewModelFactory: MenuViewModelFactoryType {
    
    func make(service: RecipeKeyServiceType) -> MenuViewModel {
        let items = [
            SidebarItem(title: "Delete API Key", type: .action)
        ]
        return MenuViewModel(service: service, items: items)
    }
}

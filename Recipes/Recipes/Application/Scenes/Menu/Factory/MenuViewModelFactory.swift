//
//  MenuViewModelFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import RecipeNetworking

protocol MenuViewModelFactoryType {
    func makeMenuViewModel(service: RecipeKeyServiceType) -> MenuViewModel
}

final class MenuViewModelFactory: MenuViewModelFactoryType {
    
    func makeMenuViewModel(service: RecipeKeyServiceType) -> MenuViewModel {
        //ToDo: inject later
        let items = [
            SidebarItem(title: "Profile", type: .navigation),
            SidebarItem(title: "MarshGradiant", type: .navigation),
            SidebarItem(title: "Transitions", type: .navigation),
            SidebarItem(title: "Logout", type: .action)
        ]
        return MenuViewModel(service: service, items: items)
    }
}

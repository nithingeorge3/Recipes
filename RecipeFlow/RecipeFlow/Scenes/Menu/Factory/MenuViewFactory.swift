//
//  MenuViewFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Foundation
import RecipeNetworking

@MainActor
protocol MenuViewFactoryType {
    func make(viewModel: MenuViewModel) -> MenuView
}

final class MenuViewFactory: MenuViewFactoryType {
    func make(viewModel: MenuViewModel) -> MenuView {
        MenuView(viewModel: viewModel)
    }
}

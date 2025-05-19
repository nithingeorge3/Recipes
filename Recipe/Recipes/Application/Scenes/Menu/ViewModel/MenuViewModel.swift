//
//  MenuViewModel.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Foundation
import RecipeNetworking
import RecipeDataStore
import SwiftData

class MenuViewModel: ObservableObject {
    @Published var showDeleteConfirmation = false
    private let service: RecipeKeyServiceType
    let items: [SidebarItem]
    
    init(service: RecipeKeyServiceType, items: [SidebarItem]) {
        self.service = service
        self.items = items
    }
    
     func deleteRecipeAPIKey() {
         service.deleteRecipeAPIkey()
    }
}

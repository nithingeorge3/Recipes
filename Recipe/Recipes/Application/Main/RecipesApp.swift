//
//  RecipesApp.swift
//  Recipes
//
//  Created by Nitin George on 02/03/2025.
//

import SwiftUI
import RecipeData
import SwiftData
import RecipeUI

@main
struct RecipesApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch appCoordinator.state {
                case .loading:
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.5)
                case .ready(let coordinator):
                    coordinator.start()
                }
            }
            .task {
                await appCoordinator.initialize()
            }
        }
    }
}

//I used ObservableObject here. But we can also use @Observable macro
@MainActor
class AppCoordinator: ObservableObject {
    enum State {
        case loading
        case ready(AppTabCoordinator)
    }
    
    @Published var state: State = .loading
    private let tabBarVisibility: TabBarVisibility
    
    private let containerName: String
    
    init(containerName: String = "Recipe", tabBarVisibility: TabBarVisibility = TabBarVisibility()) {
        self.containerName = containerName
        self.tabBarVisibility = tabBarVisibility
    }
    
    func initialize() async {
        let container = DataStoreManagerFactory.makeSharedContainer(for: containerName)
        let coordinator = await AppTabCoordinatorFactory().makeAppTabCoordinator(container: container, tabBarVisibility: tabBarVisibility)
        state = .ready(coordinator)
    }
}

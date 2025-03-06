//
//  RecipesApp.swift
//  Recipes
//
//  Created by Nitin George on 02/03/2025.
//

import SwiftUI
import RecipeDataStore
import SwiftData

@main
struct RecipesApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch appCoordinator.state {
                case .loading:
                    ProgressView()
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

@MainActor
class AppCoordinator: ObservableObject {
    enum State {
        case loading
        case ready(AppTabCoordinator)
    }
    
    @Published var state: State = .loading
    
    private let containerName: String
    
    init(containerName: String = "Recipe") {
        self.containerName = containerName
    }
    
    func initialize() async {
        let container = DataStoreManagerFactory.makeSharedContainer(for: containerName)
        let coordinator = await AppTabCoordinatorFactory().makeAppTabCoordinator(container: container)
        state = .ready(coordinator)
    }
}

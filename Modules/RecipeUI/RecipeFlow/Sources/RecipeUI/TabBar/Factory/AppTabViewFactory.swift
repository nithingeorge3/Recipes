//
//  AppTabViewFactory.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI

@MainActor
protocol TabProvider {
    func view(for tabID: UUID) -> AnyView
}

@MainActor
public protocol AppTabViewFactoryType {
    func makeAppTabView() -> AppTabView
}

public final class AppTabViewFactory: AppTabViewFactoryType {
    public var coordinators: [any TabItemProviderType]
    public let tabBarVisibility: TabBarVisibility
    
    public init(coordinators: [any TabItemProviderType], tabBarVisibility: TabBarVisibility) {
        self.coordinators = coordinators
        self.tabBarVisibility = tabBarVisibility
    }
    
    var tabs: [TabItem] {
        coordinators.map { $0.tabItem }
    }
    
    public func makeAppTabView() -> AppTabView {
        AppTabView(
            tabs: tabs,
            tabProvider: self,
            tabBarVisibility: tabBarVisibility
        )
    }
}

@MainActor
extension AppTabViewFactory: TabProvider {
    func view(for tabID: UUID) -> AnyView {
        // Find the coordinator whose `tabItem` matches the `tabID`
        guard let coordinator = coordinators.first(where: { $0.tabItem.id == tabID }) else {
            return AnyView(Text("Unknown Tab").foregroundColor(.black))
        }
        
        return coordinator.start() as! AnyView
    }
}

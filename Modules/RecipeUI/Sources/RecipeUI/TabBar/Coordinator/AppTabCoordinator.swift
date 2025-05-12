//
//  AppTabCoordinator.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI

public final class AppTabCoordinator: Coordinator {
    let appTabViewFactory: AppTabViewFactory
        
    public init(appTabViewFactory: AppTabViewFactory) {
        self.appTabViewFactory = appTabViewFactory
    }
    
    public func start() -> some View {
        appTabViewFactory.makeAppTabView()
    }
}

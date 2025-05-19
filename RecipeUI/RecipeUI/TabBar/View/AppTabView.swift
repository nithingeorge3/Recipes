//
//  AppTabView.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI

struct AppTabView: View {
    @ObservedObject var tabBarVisibility: TabBarVisibility
    @State private var selectedTab: UUID
    private let tabProvider: TabProvider
    let tabs: [TabItem]

    init(tabs: [TabItem], tabProvider: TabProvider, tabBarVisibility: TabBarVisibility) {
        self.tabs = tabs
        self.tabProvider = tabProvider
        self.tabBarVisibility = tabBarVisibility
        _selectedTab = State(initialValue: tabs.first!.id)
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                tabProvider.view(for: selectedTab)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)

            if !tabBarVisibility.isHidden {
                CustomTabBar(selectedTab: $selectedTab, tabs: tabs)
                    .transition(.move(edge: .bottom))
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

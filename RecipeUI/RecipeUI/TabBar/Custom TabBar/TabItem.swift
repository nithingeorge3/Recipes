//
//  TabItem.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI

@MainActor
public protocol TabItemProviderType: Coordinator {
    var tabItem: TabItem { get }
}

@Observable
public class TabItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let icon: String
    public let color: Color
    public var badgeCount: Int?
    
    public init(title: String, icon: String, badgeCount: Int?, color: Color) {
        self.title = title
        self.icon = icon
        self.badgeCount = badgeCount
        self.color = color
    }
}

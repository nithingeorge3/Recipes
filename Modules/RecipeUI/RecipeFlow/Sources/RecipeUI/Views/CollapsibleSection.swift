//
//  CollapsibleSection.swift
//  Recipes
//
//  Created by Nitin George on 02/03/2025.
//

import SwiftUI

public struct CollapsibleSection<Content: View>: View {
    public let title: String
    @Binding public var isCollapsed: Bool
    
    @ViewBuilder public let content: () -> Content
     
    public init(title: String, isCollapsed: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self._isCollapsed = isCollapsed
        self.content = content
    }
    
    public var body: some View {
        Section {
            if !isCollapsed {
                content()
            }
        } header: {
            HStack {
                Text(title)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: isCollapsed ? "chevron.down" : "chevron.up")
                    .onTapGesture {
                        withAnimation {
                            isCollapsed.toggle()
                        }
                    }
            }
            .padding(.vertical, 8)
            .background(Color(uiColor: .systemBackground))
        }
    }
}

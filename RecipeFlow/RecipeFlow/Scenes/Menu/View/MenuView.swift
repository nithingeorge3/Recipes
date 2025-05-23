//
//  MenuView.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI
import RecipeNetworking

struct MenuView: View {
    @ObservedObject var viewModel: MenuViewModel
    @State private var selectedItem: SidebarItem?
    
    init(viewModel: MenuViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List(viewModel.items, selection: $selectedItem) { item in
            switch item.type {
            case .navigation:
                NavigationLink(item.title, value: item)
                    .font(.headline)
                    .padding(.vertical, 8)
            case .action:
                SideBarActionButton(title: item.title) {
                    viewModel.showDeleteConfirmation = true
                }
            }
        }
        .navigationTitle("More")// ToDo: move to VM
        .listStyle(.sidebar)
        .navigationSplitViewColumnWidth(200)
        .alert("Delete API Key?", isPresented: $viewModel.showDeleteConfirmation) { // ToDo: strings move to VM
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteRecipeAPIKey()
            }
        } message: {
            Text("The Recipe API Key will be deleted from Keychain.") // ToDo: move to VM
        }
    }
    
    private struct SideBarActionButton: View {
        let title: String
        let action: () -> Void
        
        var body: some View {
            Button {
                action()
            } label: {
                Text(title)
                    .font(.headline)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment:  .leading)
            .foregroundColor(title == "Delete API Key" ? .red : .primary)
        }
    }
}

// MARK: - Previews
#if DEBUG
#Preview {
    let items = [SidebarItem(title: "Delete Key", type: .action)]
    MenuView(viewModel: MenuViewModel(service: RecipeServiceFactory.makeRecipeKeyService(), items: items))
}
#endif

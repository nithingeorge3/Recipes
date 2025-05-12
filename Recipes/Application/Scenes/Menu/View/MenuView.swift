//
//  MenuView.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI
import RecipeNetworking
import RecipeFlow

struct MenuView: View {
    @ObservedObject var viewModel: MenuViewModel
    @State private var selectedItem: SidebarItem?
    
    init(viewModel: MenuViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationSplitView {
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
            .navigationTitle("More")
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(200)
        } detail: {
            if let selectedItem {
                destinationView(for: selectedItem)
            } else {
                Text("Select an item")
                    .foregroundStyle(.secondary)
            }
        }
        .alert("Delete API Key?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteRecipeAPIKey()
            }
        } message: {
            Text("The Recipe API Key will be deleted from Keychain.")
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
    
    @ViewBuilder
    private func destinationView(for item: SidebarItem) -> some View {
        switch item.title {
        case "Recipe List":
            recipesListView()
        default:
            EmptyView()
        }
    }
    
    private func recipesListView() -> some View {
        let service = RecipeListServiceFactory.makeRecipeListService()
        let viewModel = RecipesViewModel(service: service)
        return RecipesViewFactory().makeRecipesListView(viewModel: viewModel)
    }
}

// MARK: - Previews
#if DEBUG
#Preview {
    let items = [SidebarItem(title: "Recipe List", type: .navigation)]
    MenuView(viewModel: MenuViewModel(service: RecipeServiceFactory.makeRecipeKeyService(), items: items))
}
#endif

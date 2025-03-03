//
//  RecipeImageCarousel.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI
import Kingfisher

struct RecipeImageCarousel: View {
    let image: String?
    @Binding var selectedIndex: Int
    @State private var isShowingFullImage: Bool = false
    
    //I used scrollview here in case we have more images. I just added for showcasing listing more images.
    //Notmally we don't want to use scrollview and LazyHStack for single image display
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 12) {
                        let height = max(geometry.size.width - 16, 0)
                                                
                        if let url = image.validatedURL {
                            RecipeImageView(imageURL: url, height: height)
                                .containerRelativeFrame(.horizontal)
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                .id(0)
                                .onTapGesture {
                                    selectedIndex = 0
                                    isShowingFullImage = true
                                }
                        } else {
                            Image(Constants.placeHolderImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: height, height: height)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .scrollDisabled(true)// just only one image. normally we don;t wantLazyHStack for one image. I just added for future and adding more images or videos
                .contentMargins(24)
                .scrollTargetBehavior(.paging)
                .onChange(of: selectedIndex) {
                    withAnimation {
                        proxy.scrollTo(selectedIndex, anchor: .center)
                    }
                }
                .sheet(isPresented: $isShowingFullImage) {
                    Group {                        
                        if let url = image.validatedURL {
                            CatFullImageView(url: url)
                        } else {
                            Text("Image is not available")
                                .foregroundColor(.red)
                                .font(.headline)
                        }
                    }
                    
                }
            }
        }
    }
}

//
//  RecipeImageCarousel.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI
import Kingfisher

struct RecipeImageCarousel: View {
    let mediaItems: [PresentedMedia]
    @Binding var selectedIndex: Int
    @State private var presentedMedia: PresentedMedia?
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 12) {
                        let height = max(geometry.size.width - 30, 0)
                        ForEach(Array(mediaItems.enumerated()), id: \.element.id) { index, mediaItem in
                            MediaThumbnailView(mediaItem: mediaItem, height: height)
                                .id(index)
                                .onTapGesture {
                                    presentedMedia = mediaItem
                                    selectedIndex = index
                                }
                        }
                    }
                }
                .scrollDisabled(mediaItems.count == 1)
                .contentMargins(24)
                .scrollTargetBehavior(.paging)
                .onChange(of: selectedIndex) {
                    withAnimation {
                        proxy.scrollTo(selectedIndex, anchor: .center)
                    }
                }
            }
        }
        .sheet(item: $presentedMedia) { media in
            FullScreenMediaView(media: media)
        }
    }
}

struct MediaThumbnailView: View {
    let mediaItem: PresentedMedia
    let height: CGFloat

    var body: some View {
        ZStack {
            switch mediaItem {
            case .image(let url):
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(height: height)
                    .clipped()
            case .video(let url):
                Image(Constants.placeHolderImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: height, height: height)
                    .foregroundColor(.blue)
            }
            
            if case .video = mediaItem {
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
    }
}

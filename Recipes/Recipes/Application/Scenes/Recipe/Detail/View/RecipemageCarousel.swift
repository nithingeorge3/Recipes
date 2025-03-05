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
                        let width = geometry.size.width - (mediaItems.count == 1 ? 16 : 44)
                        let height = geometry.size.width - 30
                        ForEach(Array(mediaItems.enumerated()), id: \.element.id) { index, mediaItem in
                            MediaThumbnailView(
                                mediaItem: mediaItem,
                                width: width,
                                height: height
                            )
                            .id(index)
                            .padding(.leading, index == 0 ? 4 : 0)
                            .onTapGesture {
                                presentedMedia = mediaItem
                                selectedIndex = index
                            }
                        }
                    }
                    .padding(.trailing, 24) // for last item to scroll fully :)
                }
                .scrollDisabled(mediaItems.count == 1)
                .contentMargins(.leading, 4)
                .contentMargins(.trailing, 24)
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
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            Group {
                switch mediaItem {
                case .image(let url):
                    KFImage(url)
                        .resizable()
                        .scaledToFill()
                case .video(_):
                    //ToDo: we can use video image later. I just used placeholder image
                    Image(Constants.Recipe.placeholderImage)
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: width, height: height)
            .clipped()
            
            if case .video = mediaItem {
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.black.opacity(0.5))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
    }
}

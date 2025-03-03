//
//  FullScreenMediaView.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import AVKit
import SwiftUI
import Kingfisher

struct FullScreenMediaView: View {
    let media: PresentedMedia
    
    var body: some View {
        Group {
            switch media {
            case .image(let url):
                KFImage(url)
                    .resizable()
                    .scaledToFit()
                    .background(Color.black.ignoresSafeArea())
                
            case .video(let url):
                VideoPlayer(player: AVPlayer(url: url))
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

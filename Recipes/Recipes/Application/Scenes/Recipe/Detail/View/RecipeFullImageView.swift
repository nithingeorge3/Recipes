//
//  FullImageView.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI
import Kingfisher

struct CatFullImageView: View {
    let url: URL

    var body: some View {
        VStack {
            KFImage(url)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }
}

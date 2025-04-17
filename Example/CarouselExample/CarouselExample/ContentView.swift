//
//  ContentView.swift
//  CarouselExample
//
//  Created by 浅野勇大 on 2025/04/17.
//

import SwiftUI
import ImageCarousel

struct ContentView: View {
    private let aspectRatio: CGFloat = 3 / 2
    private let images = [
        "https://placehold.jp/300x200.png",
        "https://placehold.jp/3d4070/ffffff/300x200.png",
        "https://placehold.jp/3e706f/ffffff/300x200.png",
        "https://placehold.jp/70653e/ffffff/300x200.png",
        "https://placehold.jp/70433e/ffffff/300x200.png",
    ]
    
    var body: some View {
        VStack {
            Text("Image Carousel Example")
                .font(.title)
                .padding()
            Carousel(images, aspectRatio: aspectRatio) { image in
                AsyncImage(url: URL(string: image)) { image in
                    image.image?.resizable().aspectRatio(aspectRatio, contentMode: .fit)
                }
                .cornerRadius(8)
                .onTapGesture {
                    print("Tapped on image: \(image)")
                }
            }
            .isInfinite(true)
            .interItemSpacing(8)
            .itemSize(CGSize(width: 300, height: 200))
            
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}

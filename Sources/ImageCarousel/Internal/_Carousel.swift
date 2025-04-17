//
//  _Carousel.swift
//
//
//  Created by 浅野勇大 on 2024/01/17.
//

import SwiftUI

struct _Carousel<Data: RandomAccessCollection, Content: View>: UIViewControllerRepresentable {
    // MARK: Lifecycle

    init(_ data: Data, aspectRatio: CGFloat = .zero, content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.aspectRatio = aspectRatio
        self.content = content
    }

    // MARK: Internal

    typealias UIViewControllerType = HostingImageCarouselViewController<Data, Content>

    func makeUIViewController(context: Context) -> HostingImageCarouselViewController<Data, Content> {
        .init(data, content: content)
    }

    func updateUIViewController(_ uiViewController: HostingImageCarouselViewController<Data, Content>, context: Context) {
        uiViewController.data = data
        if uiViewController.itemSize == nil {
            uiViewController.itemSize = configuration.itemSize
        }
        if uiViewController.interItemSpacing == nil {
            uiViewController.interItemSpacing = configuration.interItemSpacing
        }
        if uiViewController.isInfinite == nil {
            uiViewController.isInfinite = configuration.isInfinite
        }
        if uiViewController.autoScrollInterval == nil {
            uiViewController.autoScrollInterval = configuration.autoScrollInterval
        }
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiViewController: HostingImageCarouselViewController<Data, Content>, context: Context) -> CGSize? {
        if let width = proposal.width, aspectRatio > 0 {
            return CGSize(width: width, height: width / aspectRatio)
        }
        else {
            return nil
        }
    }

    // MARK: Private

    @Environment(\.imageCarouselSwiftUIConfiguration) private var configuration: CarouselConfiguration

    private let data: Data
    private let aspectRatio: CGFloat
    private let content: (Data.Element) -> Content
}

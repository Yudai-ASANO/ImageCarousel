//
//  Carousel.swift
//
//
//  Created by 浅野勇大 on 2024/01/17.
//

import SwiftUI

public struct Carousel: View {
    // MARK: Lifecycle

    public init<Data: RandomAccessCollection>(_ data: Data, aspectRatio: CGFloat = .zero, @ViewBuilder content: @escaping (Data.Element) -> some View) {
        self.aspectRatio = aspectRatio
        internalBody = AnyView(_Carousel(data, aspectRatio: aspectRatio, content: content))
    }

    // MARK: Public

    public var body: some View {
        internalBody
            .environment(\.imageCarouselSwiftUIConfiguration, configuration)
    }

    public func itemSize(_ itemSize: CGSize) -> Self {
        then { $0.configuration.itemSize = itemSize }
    }

    public func interItemSpacing(_ interItemSpacing: CGFloat) -> Self {
        then { $0.configuration.interItemSpacing = interItemSpacing }
    }

    public func isInfinite(_ isInfinite: Bool) -> Self {
        then { $0.configuration.isInfinite = isInfinite }
    }

    public func autoScrollInterval(_ autoScrollInterval: TimeInterval) -> Self {
        then { $0.configuration.autoScrollInterval = autoScrollInterval }
    }

    // MARK: Private

    private let internalBody: AnyView
    private let aspectRatio: CGFloat
    private var configuration: CarouselConfiguration = nil
}

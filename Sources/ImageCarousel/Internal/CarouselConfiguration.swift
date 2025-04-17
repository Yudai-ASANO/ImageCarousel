//
//  CarouselConfiguration.swift
//
//
//  Created by 浅野勇大 on 2024/01/17.
//

import SwiftUI

// MARK: - CarouselConfiguration

struct CarouselConfiguration: ExpressibleByNilLiteral {
    // MARK: Lifecycle

    init(nilLiteral: ()) {}

    // MARK: Internal

    var itemSize: CGSize = .zero
    var interItemSpacing: CGFloat = .zero
    var isInfinite = false
    var autoScrollInterval: TimeInterval = .zero
}

// MARK: - ImageCarouselSwiftUIConfigurationKey

struct ImageCarouselSwiftUIConfigurationKey: EnvironmentKey {
    static let defaultValue: CarouselConfiguration = nil
}

extension EnvironmentValues {
    var imageCarouselSwiftUIConfiguration: CarouselConfiguration {
        get {
            self[ImageCarouselSwiftUIConfigurationKey.self]
        }
        set {
            self[ImageCarouselSwiftUIConfigurationKey.self] = newValue
        }
    }
}

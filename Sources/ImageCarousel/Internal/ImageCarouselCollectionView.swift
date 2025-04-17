//
//  ImageCarouselCollectionView.swift
//
//
//  Created by 浅野勇大 on 2024/01/15.
//

import UIKit

class ImageCarouselCollectionView: UICollectionView {
    // MARK: Lifecycle

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: Internal

    override var scrollsToTop: Bool {
        get {
            return false
        }
        // swiftlint:disable unused_setter_value
        set {
            super.scrollsToTop = false
        }
        // swiftlint:enable unused_setter_value
    }

    // MARK: Private

    private func commonInit() {
        contentInset = .zero
        decelerationRate = .fast
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        scrollsToTop = false
        isPagingEnabled = false
        contentInsetAdjustmentBehavior = .never
    }
}

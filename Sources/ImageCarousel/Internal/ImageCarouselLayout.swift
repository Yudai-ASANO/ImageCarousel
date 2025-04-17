//
//  ImageCarouselLayout.swift
//
//
//  Created by 浅野勇大 on 2024/01/15.
//

import Combine
import UIKit

final class ImageCarouselLayout: UICollectionViewFlowLayout {
    // MARK: Lifecycle

    override init() {
        super.init()
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    // MARK: Internal

    override class var layoutAttributesClass: AnyClass {
        ImageCarouselLayoutAttributes.self
    }

    override var collectionViewContentSize: CGSize {
        contentSize
    }

    // レイアウトが再計算を必要とするかどうか
    // trueの場合、レイアウトは再計算される
    var needsReprepare = true
    // UICollectionViewのContentSize
    // CollectionView内の全アイテムを含めたサイズ
    var contentSize: CGSize = .zero
    // CollectionViewの先頭と最初のアイテムの間のスペース
    var leadingSpacing: CGFloat = 0
    // アイテム間のスペースとアイテムの幅の合計
    var segmentWidth: CGFloat = 0

    override func prepare() {
        guard let collectionView, let imageCarousel else {
            return
        }

        guard needsReprepare else {
            return
        }

        needsReprepare = false

        numberOfSections = imageCarousel.numberOfSections(in: collectionView)
        numberOfItems = imageCarousel.collectionView(collectionView, numberOfItemsInSection: 0)
        actualInterItemSpacing = imageCarousel.interItemSpacing
        actualItemSize = {
            // itemSizeが指定されていない場合は、collectionViewのサイズを使用する
            var size = imageCarousel.itemSize
            if size == .zero {
                size = collectionView.bounds.size
            }
            return size
        }()

        // 先頭と最後のアイテムの間のスペースを計算する
        leadingSpacing = (collectionView.frame.width - actualItemSize.width) / 2
        // アイテム間のスペースを計算する
        segmentWidth = actualInterItemSpacing + actualItemSize.width
        contentSize = {
            // 全アイテム数を計算する
            let numberOfTotalItems = numberOfItems * numberOfSections
            // 先頭と最後のアイテムの間のスペースを計算する
            var contentSizeWidth: CGFloat = leadingSpacing * 2
            // アイテム間のスペースを計算する
            contentSizeWidth += CGFloat(numberOfTotalItems - 1) * actualInterItemSpacing
            // アイテムのサイズを計算する
            contentSizeWidth += CGFloat(numberOfTotalItems) * actualItemSize.width
            let contentSize = CGSize(width: contentSizeWidth, height: collectionView.frame.height)
            return contentSize
        }()

        updateCollectionViewBounds()
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()

        // itemSpacing が正であり、かつ与えられた矩形が空でないことを確認
        guard segmentWidth > 0, !rect.isEmpty else {
            return layoutAttributes
        }

        // 与えられた矩形とコンテンツサイズの交差を計算し、空でないことを確認
        let intersectedRect = rect.intersection(CGRect(origin: .zero, size: contentSize))
        guard !intersectedRect.isEmpty else {
            return layoutAttributes
        }

        // 矩形内の最初のアイテムのインデックスを計算
        let numberOfItemsBefore = max(Int((intersectedRect.minX - leadingSpacing) / segmentWidth), 0)

        // 最初のアイテムの位置と最大位置を計算
        let startPosition = leadingSpacing + CGFloat(numberOfItemsBefore) * segmentWidth
        let maxPosition = min(intersectedRect.maxX, contentSize.width - actualItemSize.width - leadingSpacing)

        // 現在のアイテムインデックスとアイテムの位置を初期化
        var itemIndex = numberOfItemsBefore
        var origin = startPosition

        // origin が maxPosition に十分近いかを判断するための閾値を設定（この条件じゃないと不具合が発生）
        // 以下を参考に作成
        // https://github.com/WenchaoD/FSPagerView/blob/968f0aaf120b8cb97d12c3a4447daa4926029f67/Sources/FSPageViewLayout.swift#L129
        let threshold = max(
            CGFloat(100.0) * .ulpOfOne * abs(origin + maxPosition),
            .leastNonzeroMagnitude
        )

        while origin - maxPosition <= threshold {
            // 現在のセクションとアイテムのインデックスを計算
            let section = itemIndex / numberOfItems
            let item = itemIndex % numberOfItems
            let indexPath = IndexPath(item: item, section: section)

            // レイアウト属性を作成
            let attributes = ImageCarouselLayoutAttributes(forCellWith: indexPath)
            attributes.frame = itemFrame(for: indexPath)

            // レイアウト属性を配列に追加
            layoutAttributes.append(attributes)

            // 次のアイテムの位置とインデックスを更新
            origin += segmentWidth
            itemIndex += 1
        }

        return layoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribute = ImageCarouselLayoutAttributes(forCellWith: indexPath)
        attribute.indexPath = indexPath
        let frame = itemFrame(for: indexPath)
        let center = CGPoint(x: frame.midX, y: frame.midY)
        attribute.center = center
        attribute.size = actualItemSize
        return attribute
    }

    override func targetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint,
        withScrollingVelocity velocity: CGPoint
    ) -> CGPoint {
        guard let collectionView else {
            return proposedContentOffset
        }

        let boundedOffset = collectionView.contentSize.width - segmentWidth
        var targetOffsetX: CGFloat = if velocity.x > 0.3 {
            ceil(collectionView.contentOffset.x / segmentWidth) * segmentWidth
        }
        else if velocity.x < -0.3 {
            floor(collectionView.contentOffset.x / segmentWidth) * segmentWidth
        }
        else {
            round(proposedContentOffset.x / segmentWidth) * segmentWidth
        }

        targetOffsetX = max(0, min(targetOffsetX, boundedOffset))
        return CGPoint(x: targetOffsetX, y: proposedContentOffset.y)
    }

    func forceInvalidate() {
        needsReprepare = true
        invalidateLayout()
    }

    // 指定されたindexPathにあるアイテムがビューポートの中央に配置されるようにするためのcontentOffsetを計算する
    func itemContentOffset(for indexPath: IndexPath) -> CGPoint {
        let origin = itemFrame(for: indexPath).origin
        guard let collectionView else {
            return origin
        }
        let contentOffsetX = origin.x - (collectionView.frame.width - actualItemSize.width) / 2
        let contentOffsetY = CGFloat.zero
        let contentOffset = CGPoint(x: contentOffsetX, y: contentOffsetY)
        return contentOffset
    }

    // 指定されたindexPathのアイテムのフレーム（位置とサイズ）を計算する
    func itemFrame(for indexPath: IndexPath) -> CGRect {
        guard let collectionView else {
            return .zero
        }
        // 指定されたindexPathまでの累積アイテムインデックス
        // これまでのセクションを通じたアイテムのインデックスの合計
        let cumulativeItemIndex = numberOfItems * indexPath.section + indexPath.item
        let originX = leadingSpacing + CGFloat(cumulativeItemIndex) * segmentWidth
        let originY = (collectionView.frame.height - actualItemSize.height) / 2
        let origin = CGPoint(x: originX, y: originY)
        let frame = CGRect(origin: origin, size: actualItemSize)
        return frame
    }

    // MARK: Private

    // CollectionView内のセクション数
    // Prepare時にImageCarouselから取得される
    private var numberOfSections: Int = 1
    // CollectionView内の各セクションに含まれるアイテム数（すべてのセクションでアイテム数は同じ）
    // Prepare時にImageCarouselから取得される
    private var numberOfItems: Int = 0
    // 実際のアイテム間のスペース
    // Prepare時にImageCarouselから取得される
    private var actualInterItemSpacing: CGFloat = 0
    // 実際のアイテムサイズ
    // Prepare時にImageCarouselの設定、またはCollectionViewのフレームサイズに基づいて計算される。
    private var actualItemSize: CGSize = .zero
    // orientationDidChangeNotificationTaskのキャンセルトークン
    private var cancellable: AnyCancellable?

    private var imageCarousel: ImageCarousel? {
        collectionView?.superview?.superview as? ImageCarousel
    }

    private func commonInit() {
        scrollDirection = .horizontal
        let notificationCenter = NotificationCenter.default
        cancellable = notificationCenter.publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { [weak self] _ in
                if self?.imageCarousel?.itemSize == .zero {
                    self?.forceInvalidate()
                }
            }
    }

    // 現在のindexに基づいて、CollectionViewのboundsを更新する
    // 無限カルーセルをサポートする場合、選択されたアイテムが中央に表示されるようにCollectionViewのboundsを更新している
    private func updateCollectionViewBounds() {
        guard let collectionView, let imageCarousel else {
            return
        }
        let currentIndex = imageCarousel.currentIndex
        let updateIndexPath = IndexPath(
            item: currentIndex,
            section: imageCarousel.isInfinite ? numberOfSections / 2 : 0
        )
        let contentOffset = itemContentOffset(for: updateIndexPath)
        let updateBounds = CGRect(origin: contentOffset, size: collectionView.frame.size)
        collectionView.bounds = updateBounds
    }
}

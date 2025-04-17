//
//  ImageCarousel.swift
//  ImageCarousel
//
//  Created by 浅野勇大 on 2024/01/14.
//

import Combine
import UIKit

// MARK: - ImageCarouselDelegate

public protocol ImageCarouselDelegate: AnyObject {
    func imageCarousel(_ imageCarousel: ImageCarousel, didSelectItemAt index: Int)
    func imageCarousel(_ imageCarousel: ImageCarousel, didChangeItemAt index: Int)
}

// MARK: - ImageCarouselDataSource

public protocol ImageCarouselDataSource: AnyObject {
    func numberOfItems(in imageCarousel: ImageCarousel) -> Int
    func imageCarousel(_ imageCarousel: ImageCarousel, cellForItemAt index: Int) -> UICollectionViewCell
}

// MARK: - ImageCarousel

public final class ImageCarousel: UIView {
    // MARK: Lifecycle

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    // MARK: Internal

    public weak var delegate: ImageCarouselDelegate?
    public weak var dataSource: ImageCarouselDataSource?

    public var autoScrollInterval: TimeInterval = .zero {
        didSet {
            if autoScrollInterval > 0 {
                startTimer(timeInterval: autoScrollInterval)
            }
            else {
                stopTimer()
            }
        }
    }

    public var interItemSpacing: CGFloat = 0 {
        didSet {
            collectionViewLayout.forceInvalidate()
        }
    }

    public var itemSize: CGSize = .zero {
        didSet {
            collectionViewLayout.forceInvalidate()
        }
    }

    public var isInfinite = false {
        didSet {
            reloadData()
        }
    }

    public private(set) var currentIndex: Int = 0 {
        didSet {
            delegate?.imageCarousel(self, didChangeItemAt: currentIndex)
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        collectionView.frame = contentView.bounds
    }

    public func reloadData() {
        collectionViewLayout.needsReprepare = true
        collectionView.reloadData()
    }

    public func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }

    public func dequeueReusableCell(withReuseIdentifier identifier: String, for index: Int) -> UICollectionViewCell {
        let indexPath = IndexPath(item: index, section: dequeingIndexForSection)
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }

    public func dequeueReusableCell<Cell, Item>(using registration: UICollectionView.CellRegistration<Cell, Item>, for index: Int, item: Item?) -> Cell where Cell: UICollectionViewCell {
        let indexPath = IndexPath(item: index, section: dequeingIndexForSection)
        return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
    }

    // MARK: Private

    private var collectionViewLayout: ImageCarouselLayout!
    private var collectionView: ImageCarouselCollectionView!
    private var contentView: UIView!
    private var numberOfItems: Int = 0
    private var numberOfSections: Int = 0
    private var dequeingIndexForSection: Int = 0
    private var cancellable: AnyCancellable?

    private var scrollOffset: CGFloat {
        let scrollOffset = Double(collectionView.contentOffset.x / collectionViewLayout.segmentWidth)
        return fmod(CGFloat(scrollOffset), CGFloat(numberOfItems))
    }

    private var centermostIndexPath: IndexPath {
        // コレクションビューにアイテムがない、またはコンテンツサイズがゼロの場合は、最初のインデックスパスを返す
        guard numberOfItems > 0, collectionView.contentSize != .zero else {
            return IndexPath(item: 0, section: 0)
        }

        // 表示中のアイテムのインデックスパスを取得し、中心に最も近いものを見つける
        let sortedIndexPaths = collectionView.indexPathsForVisibleItems.sorted { leftIndexPath, rightIndexPath -> Bool in
            // 左右のアイテムの中心位置を計算
            let leftCenter: CGFloat = collectionViewLayout.itemFrame(for: leftIndexPath).midX
            let rightCenter: CGFloat = collectionViewLayout.itemFrame(for: rightIndexPath).midX

            // コレクションビューの中心位置を計算
            let ruler: CGFloat = collectionView.bounds.midX

            // 中心に最も近いアイテムを決定する
            return abs(ruler - leftCenter) < abs(ruler - rightCenter)
        }

        // ソートされたインデックスパスの最初のもの（最も中心に近いアイテム）を返す
        // もし見つからなければ、最初のインデックスパスを返す
        return sortedIndexPaths.first ?? IndexPath(item: 0, section: 0)
    }

    private func commonInit() {
        let contentView = UIView(frame: .zero)
        contentView.backgroundColor = nil
        addSubview(contentView)
        self.contentView = contentView
        let collectionViewLayout = ImageCarouselLayout()
        let collectionView = ImageCarouselCollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = nil
        collectionView.delegate = self
        collectionView.dataSource = self
        contentView.addSubview(collectionView)
        self.collectionView = collectionView
        self.collectionViewLayout = collectionViewLayout
    }

    private func startTimer(timeInterval: TimeInterval) {
        cancellable?.cancel()
        cancellable = Timer.publish(every: timeInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.flipToNext()
            }
    }

    private func stopTimer() {
        cancellable?.cancel()
    }

    private func flipToNext() {
        guard numberOfItems > 0 else {
            return
        }
        let nextItemContentOffset: CGPoint = {
            let indexPath = centermostIndexPath
            let section = numberOfSections > 1 ? (indexPath.section + (indexPath.item + 1) / numberOfItems) : 0
            let item = (indexPath.item + 1) % numberOfItems
            return collectionViewLayout.itemContentOffset(for: IndexPath(item: item, section: section))
        }()
        collectionView.setContentOffset(nextItemContentOffset, animated: true)
    }
}

// MARK: UICollectionViewDataSource

extension ImageCarousel: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        numberOfItems
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let dataSource else {
            numberOfItems = 0
            return 0
        }
        numberOfItems = dataSource.numberOfItems(in: self)
        guard numberOfItems > 0 else {
            return 0
        }
        numberOfSections = numberOfItems > 1 && isInfinite ? kInfiniteScrollThreshold / numberOfItems : 1
        return numberOfSections
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataSource else {
            return UICollectionViewCell()
        }
        let index = indexPath.item % numberOfItems
        dequeingIndexForSection = indexPath.section
        return dataSource.imageCarousel(self, cellForItemAt: index)
    }
}

// MARK: UICollectionViewDelegate

extension ImageCarousel: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 自動スクロールではユーザインタラクションによって中心以外で静止することがあるため、セルの中心にスクロールする処理をいれる
        let contentOffset = collectionViewLayout.itemContentOffset(for: indexPath)
        collectionView.setContentOffset(contentOffset, animated: true)
        // インデックスパスを正規化してからデリゲートに通知する
        let index = indexPath.item % numberOfItems
        delegate?.imageCarousel(self, didSelectItemAt: index)
    }
}

// MARK: UIScrollViewDelegate

extension ImageCarousel: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if numberOfItems > 0 {
            let currentIndex = lround(Double(scrollOffset)) % numberOfItems
            if self.currentIndex != currentIndex {
                self.currentIndex = currentIndex
            }
        }
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if autoScrollInterval > 0 {
            stopTimer()
        }
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if autoScrollInterval > 0 {
            startTimer(timeInterval: autoScrollInterval)
        }
    }
} 

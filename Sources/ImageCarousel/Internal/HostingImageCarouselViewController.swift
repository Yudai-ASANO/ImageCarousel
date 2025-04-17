//
//  HostingImageCarouselViewController.swift
//
//
//  Created by 浅野勇大 on 2024/01/16.
//

import SwiftUI
import UIKit

final class HostingImageCarouselViewController<Data: RandomAccessCollection, Content: View>: UIViewController, ImageCarouselDelegate, ImageCarouselDataSource {
    // MARK: Lifecycle

    init(_ data: Data, content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    override var navigationController: UINavigationController? {
        nil
    }

    lazy var imageCarousel: ImageCarousel = {
        let imageCarousel = ImageCarousel()
        imageCarousel.delegate = self
        imageCarousel.dataSource = self
        return imageCarousel
    }()

    var itemSize: CGSize? {
        didSet {
            if let itemSize {
                imageCarousel.itemSize = itemSize
            }
        }
    }

    var interItemSpacing: CGFloat? {
        didSet {
            if let interItemSpacing {
                imageCarousel.interItemSpacing = interItemSpacing
            }
        }
    }

    var isInfinite: Bool? {
        didSet {
            if let isInfinite {
                imageCarousel.isInfinite = isInfinite
            }
        }
    }

    var autoScrollInterval: TimeInterval? {
        didSet {
            if let autoScrollInterval {
                imageCarousel.autoScrollInterval = autoScrollInterval
            }
        }
    }

    var data: Data {
        didSet {
            imageCarousel.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        view.backgroundColor = nil
        view.addSubview(imageCarousel)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        imageCarousel.frame = view.bounds
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // メモリ解放
        hostingControllers.removeAll()
    }

    // MARK: ImageCarouselDelegate

    func imageCarousel(_ imageCarousel: ImageCarousel, didSelectItemAt index: Int) {}

    func imageCarousel(_ imageCarousel: ImageCarousel, didChangeItemAt index: Int) {}

    // MARK: ImageCarouselDataSource

    func numberOfItems(in imageCarousel: ImageCarousel) -> Int {
        data.count
    }

    func imageCarousel(_ imageCarousel: ImageCarousel, cellForItemAt index: Int) -> UICollectionViewCell {
        let dataIndex = data.index(data.startIndex, offsetBy: index)
        if dataIndex < data.endIndex {
            return imageCarousel.dequeueReusableCell(using: cellRegistration, for: index, item: data[dataIndex])
        }
        else {
            return UICollectionViewCell()
        }
    }

    // MARK: Private

    private let content: (Data.Element) -> Content

    private var cellRegistration: UICollectionView.CellRegistration<UICollectionViewCell, Data.Element>!
    private var hostingControllers: [Int: UIHostingController<Content>] = [:]

    private func registerCell() {
        cellRegistration = UICollectionView.CellRegistration(handler: { [unowned self] cell, _, itemIdentifier in
            cell.contentConfiguration = UIHostingConfiguration(content: {
                content(itemIdentifier)
            })
            .margins(.all, 0)
        })
    }
}

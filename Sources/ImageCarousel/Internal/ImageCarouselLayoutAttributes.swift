//
//  ImageCarouselLayoutAttributes.swift
//
//
//  Created by 浅野勇大 on 2024/02/07.
//

import UIKit

final class ImageCarouselLayoutAttributes: UICollectionViewLayoutAttributes {
    var position: CGFloat = 0

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? ImageCarouselLayoutAttributes else {
            return false
        }
        var isEqual = super.isEqual(object)
        isEqual = isEqual && (position == object.position)
        return isEqual
    }

    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! ImageCarouselLayoutAttributes
        copy.position = position
        return copy
    }
}

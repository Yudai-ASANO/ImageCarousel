//
//  UIView++.swift
//
//
//  Created by 浅野勇大 on 2024/06/25.
//

import UIKit

extension UIView {
    func ignoreSafeAreaInsets() {
        if #available(iOS 15.0, *) {
            self.insetsLayoutMarginsFromSafeArea = false
        }
    }
}

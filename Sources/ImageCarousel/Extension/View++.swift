//
//  View++.swift
//
//
//  Created by 浅野勇大 on 2024/01/17.
//

import SwiftUI

extension View {
    func then(_ body: (inout Self) -> Void) -> Self {
        var result = self

        body(&result)

        return result
    }
}

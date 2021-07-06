//
//  ImageWrapper.swift
//  DWDWatch
//
//  Created by Léon Friedmann on 06.07.21.
//

import Foundation
import SwiftUI

struct ImageWrapper: Identifiable, Hashable {
    let id: UUID
    let image: NSImage
    let date: Date
    
    init?(image: NSImage?, date: Date) {
        guard let image = image else {
            return nil
        }
        self.image = image
        self.date = date
        self.id = UUID()
    }
}

extension ImageWrapper: Comparable {
    static func < (lhs: ImageWrapper, rhs: ImageWrapper) -> Bool {
        lhs.date < rhs.date
    }
}

//
//  Pressable.swift
//  DeleteMe
//
//  Created by Anders on 3/13/24.
//

import UIKit

/// A protocol that gives any UIView pressable behavior
protocol Pressable: UIView {
    func pressable(isPressed: Bool)
}

extension Pressable {
    
    /// Transforms the view into the pressable state when `isPressed` is `true`
    func pressable(isPressed: Bool) {
        UIView.animate(withDuration: 0.15) {
            if isPressed {
                self.transform = CGAffineTransform(scaleX: 0.95,
                                                   y: 0.95)
            } else {
                self.transform = CGAffineTransform.identity
            }
        }
    }
    
}

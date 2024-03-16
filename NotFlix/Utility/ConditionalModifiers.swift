//
//  ConditionalModifiers.swift
//  NotFllix
//
//  Created by Anders on 3/15/24.
//

import SwiftUI

extension View {
    
    @ViewBuilder
    func `if`<T: View>(_ value: Bool, @ViewBuilder modifier: (Self) -> T) -> some View {
        if value {
            modifier(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func `ifLet`<Value, T: View>(_ value: Value?, @ViewBuilder modifier: (Self, Value) -> T) -> some View {
        if let value = value {
            modifier(self, value)
        } else {
            self
        }
    }
    
}

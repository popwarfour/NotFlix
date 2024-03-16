//
//  DidAppearModifier.swift
//  NotFllix
//
//  Created by Anders on 3/16/24.
//

import SwiftUI

extension View {
    
    /// A convenienece for adding an `onAppear` modifier that flips the binding's wrapped value to true when fired.
    func didAppear(binding: Binding<Bool>) -> some View {
        modifier(DidAppearModifier(didAppear: binding))
    }
    
}

private struct DidAppearModifier: ViewModifier {
    
    @Binding var didAppear: Bool
    
    func body(content: Content) -> some View {
        content
            .onAppear(perform: { didAppear = true })
    }
    
}

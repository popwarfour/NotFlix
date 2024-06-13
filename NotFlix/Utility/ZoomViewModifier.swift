//
//  ZoomViewModifier.swift
//  NotFllix
//
//  Created by Anders on 3/16/24.
//

import SwiftUI

extension View {
    func zoom(show: Binding<Bool>, scale: Double = 2) -> some View {
        modifier(ZoomViewModifier(show: show, scale: scale))
    }
}

private struct ZoomViewModifier: ViewModifier {
    
    @State private var result = GeometryReaderResult.empty()
    @Binding var show: Bool
    let scale: Double
    
    func body(content: Content) -> some View {
        content
            .geometryReader(result: $result)
            .overlay {
                content
                    .frame(width: show ? result.size.width * scale : result.size.width,
                           height:  show ? result.size.height * scale : result.size.height)
                    .opacity(show ? 0.75 : 1)
            }
            .zIndex(1)
    }
    
}

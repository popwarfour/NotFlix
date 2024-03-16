//
//  GeometryReaderOverlay.swift
//  NotFllix
//
//  Created by Anders on 3/14/24.
//

import SwiftUI

// MARK: - GeometryReaderResult

/// A container that encapsulates the result of a geometry reader view modifier. Effectively a wrapper around `GeometryProxy`
struct GeometryReaderResult: Equatable {
    
    /// A container a holds the resolved frame for the supplied coordinate space
    struct Frame: Equatable {
        let frame: CGRect
        let coordinateSpace: CoordinateSpace
        
        fileprivate init(frame: CGRect, coordinateSpace: CoordinateSpace) {
            self.frame = frame
            self.coordinateSpace = coordinateSpace
        }
    }
    
    /// The size of the container view.
    let size: CGSize
    /// The safe area inset of the container view.
    let safeAreaInsets: EdgeInsets
    /// The container view's bounds rectangle with respect to the coordinate space. The `local` coordinate space is used if none was supplied
    let frame: Frame
    
    fileprivate init(proxy: GeometryProxy, coordinateSpace: CoordinateSpaceProtocol) {
        self.init(size: proxy.size,
                  safeAreaInsets: proxy.safeAreaInsets,
                  frame: .init(frame: proxy.frame(in: coordinateSpace),
                               coordinateSpace: coordinateSpace.coordinateSpace))
    }
    
    private init(size: CGSize,
                 safeAreaInsets: EdgeInsets,
                 frame: Frame) {
        self.size = size
        self.safeAreaInsets = safeAreaInsets
        self.frame = frame
    }
    
    static func empty() -> Self {
        .init(size: .zero,
              safeAreaInsets: .init(),
              frame: .init(frame: .zero, coordinateSpace: .local))
    }
    
}

// MARK: - View Modifier

// MARK: Configuration

/// The configuration for geometry reader modifier
struct GeometryReaderConfiguration {
    /// The mode in which the geometry reader is applied
    let mode: Mode
    /// The coordinate spacd
    let coordinateSpace: CoordinateSpaceProtocol
    /// Should we surpress result updates if the size is `.zero`. Helpful for suppressing unnesessary updates
    let ignoresZeroSize: Bool = false
    
    /// Creates an instance
    /// - Parameters:
    ///   - mode: The mode in which the geometry reader is applied
    ///   - ignoresZeroSize: Should we surpress result updates if the size is `.zero`. Helpful for suppressing unnesessary updates
    ///   - coordinateSpace: The coordinate space used to compute the ``GeometryReaderResult/frame-swift.property``. Defaults to the local coordinate space
    init(mode: Mode = .overlay,
         ignoresZeroSize: Bool = false,
         coordinateSpace: CoordinateSpaceProtocol = LocalCoordinateSpace()) {
        self.mode = mode
        self.coordinateSpace = coordinateSpace
    }
    
    /// The mode in which the geometry reader is applied
    enum Mode {
        /// The geometry reader is applied as an overlay. This provides you with an accurate side of the parent view.
        case overlay
        /// The geometry reader wraps the content just like a native implementation
        case normal
    }
}

// MARK: View Extensions

extension View {
    
    func geometryReader(_ configuration: GeometryReaderConfiguration = .init(),
                        result: @escaping (GeometryReaderResult) -> Void) -> some View {
        self.modifier(
            GeometryReaderOverlay(configuration: configuration,
                                  result: result)
        )
    }
    
    func geometryReader(_ configuration: GeometryReaderConfiguration = .init(),
                        result: Binding<GeometryReaderResult>) -> some View {
        self.modifier(
            GeometryReaderOverlay(configuration: configuration,
                                  result: { result.wrappedValue = $0 })
        )
    }
    
}

// MARK: Modifier

private struct GeometryReaderOverlay: ViewModifier {
    
    let configuration: GeometryReaderConfiguration
    let result: (GeometryReaderResult) -> Void
    
    @State private var didAppear = false
    
    private func shouldWritePreferenceKey(size: CGSize) -> Bool {
        guard didAppear else { return false }
        guard !configuration.ignoresZeroSize || !(size.width == 0 || size.height == 0) else { return false }
        return true
    }
    
    func body(content: Content) -> some View {
        switch configuration.mode {
        case .overlay:
            overlay(content: content)
        case .normal:
            normal(content: content)
        }
    }
    
    @ViewBuilder
    private func normal(content: Content) -> some View {
        GeometryReader(content: { proxy in
            content
                .didAppear(binding: $didAppear)
                .if(shouldWritePreferenceKey(size: proxy.size), modifier: {
                    $0.preference(
                        key: GeometryReaderPreferenceKey.self,
                        value: .init(proxy: proxy, coordinateSpace: configuration.coordinateSpace)
                    )
                })
        })
        .onPreferenceChange(GeometryReaderPreferenceKey.self, perform: result)
    }
    
    @ViewBuilder
    private func overlay(content: Content) -> some View {
        content
            .overlay {
            GeometryReader(content: { proxy in
                Color
                    .clear
                    .didAppear(binding: $didAppear)
                    .if(shouldWritePreferenceKey(size: proxy.size), modifier: {
                        $0.preference(
                            key: GeometryReaderPreferenceKey.self,
                            value: .init(proxy: proxy, coordinateSpace: configuration.coordinateSpace)
                        )
                    })
            })
        }
        .onPreferenceChange(GeometryReaderPreferenceKey.self, perform: result)
    }
    
}

// MARK: Preference Key

private struct GeometryReaderPreferenceKey: PreferenceKey {
    static let defaultValue = GeometryReaderResult.empty()
    
    static func reduce(value: inout GeometryReaderResult, nextValue: () -> GeometryReaderResult) {
        let next = nextValue()
        if next != value {
            // Value Different
            value = next
        }
    }
}

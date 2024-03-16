//
//  ObservableScrollView.swift
//  NotFllix
//
//  Created by Anders on 3/15/24.
//

import SwiftUI

// MARK: - ObservableScrollView

extension ScrollView {
    
    static func observable(_ axis: Axis.Set,
                           configuration: ObservableScrollViewConfiguration = .init(),
                           @ViewBuilder content: @escaping () -> Content) -> some View {
        ObservableScrollView(axis: axis,
                             configuration: configuration,
                             content: content)
    }
    
}

/// A configuration for the `ObservableScrollView`
struct ObservableScrollViewConfiguration {
    /// Should a geometry reader be placed on the content view
    let includeContent: Bool
    
    /// Creates an instance
    /// - Parameter includeContent: Should a geometry reader be placed on the content view
    init(includeContent: Bool = true) {
        self.includeContent = includeContent
    }
}

private struct ObservableScrollView<Content: View>: View {
    
    let axis: Axis.Set
    let configuration: ObservableScrollViewConfiguration
    @ViewBuilder let content: () -> Content
    
    init(axis: Axis.Set,
         configuration: ObservableScrollViewConfiguration,
         content: @escaping () -> Content) {
        self.axis = axis
        self.configuration = configuration
        self.content = content
    }
    
    @State private var scrollViewFrame = GeometryReaderResult.empty()
    @State private var scrollViewContent: GeometryReaderResult? = nil
    
    var body: some View {
        ScrollView.init(axis) {
            content()
                .if(configuration.includeContent, modifier: {
                    $0.geometryReader { scrollViewContent = $0 }
                })
                .environment(\.observable, .init(scrollViewCoordinateSpace: .scrollView,
                                                 scrollViewFrame: scrollViewFrame,
                                                 scrollViewContent: scrollViewContent))
        }
        .geometryReader(result: $scrollViewFrame)
    }
    
}

/// A container that encapsulates the result of a observable scroll view
struct ObservableScrollViewResult {
    /// The coordinate space for the scroll view
    let scrollViewCoordinateSpace: NamedCoordinateSpace
    /// The geometry result of the scroll views frame
    let scrollViewFrame: GeometryReaderResult
    /// An optional geometry result of the content within the scroll view if set via the ``ObservableScrollViewConfiguration/includeContent`` property
    let scrollViewContent: GeometryReaderResult?
}

private struct ObservableEnvironmentKey: EnvironmentKey {
    static let defaultValue: ObservableScrollViewResult? = nil
}

extension EnvironmentValues {
    var observable: ObservableScrollViewResult? {
        get { self[ObservableEnvironmentKey.self] }
        set { self[ObservableEnvironmentKey.self] = newValue }
    }
}

// MARK: - Frame Within Scroll View

extension View {
    
    /// A modifier that gives you the views `CGRect` frame relative to the inner most `ScrollView`
    func frameWithinScrollView(closure: @escaping (CGRect) -> Void) -> some View {
        modifier(FrameWithinScrollViewViewModifier(closure: closure))
    }
    
}

private struct FrameWithinScrollViewViewModifier: ViewModifier {
    
    let closure: (CGRect) -> Void
    
    func body(content: Content) -> some View {
        content
            .geometryReader(.init(coordinateSpace: NamedCoordinateSpace.scrollView)) { result in
                closure(result.frame.frame)
            }
    }
    
}

// MARK: - Observed Visibility

extension View {
    
    /// A modifier that gives you a boolean if the view is visible with respect to the inner most `ObservableScrollView`
    func observedVisibility(closure: @escaping (_ visible: Bool) -> Void) -> some View {
        modifier(ObservedVisibilityViewModifier(closure: closure))
    }
    
    /// A modifier that gives you a boolean if the view is visible with respect to the inner most `ObservableScrollView`
    func observedVisibility(visible: Binding<Bool>) -> some View {
        modifier(ObservedVisibilityViewModifier(closure: { visible.wrappedValue = $0 }))
    }
    
}

private struct ObservedVisibilityViewModifier: ViewModifier {
    
    @Environment(\.observable) var observable
    @State private var previousValue: Bool? = nil
    @State private var didAppear = false
    
    let closure: (_ visible: Bool) -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear(perform: {
                didAppear = true
                // Updated
                previousValue = true
                closure(true)
            })
            .ifLet(observable, modifier: { view, observable in
                view.frameWithinScrollView { frame in
                    let scrollViewBounds = CGRect(
                        origin: .zero,
                        size: observable.scrollViewFrame.size
                    )
                    let isVisible = frame.intersects(scrollViewBounds)
                    if let previousValue, previousValue == isVisible {
                        // Skip
                        return
                    }
                    // Updated
                    previousValue = isVisible
                    closure(isVisible)
                }
            })
    }
    
}

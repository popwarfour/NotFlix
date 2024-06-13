//
//  SwiftUICarouselView.swift
//  NotFllix
//
//  Created by Anders on 3/14/24.
//

import SwiftUI

// MARK: - SwiftUIHomepageCarouselView

struct SwiftUIHomepageCarouselView: View {
    
    typealias ViewModel = HomepageCarouselViewModel
    let viewModel: ViewModel
    
    var body: some View {
        ScrollView.observable(.horizontal, configuration: .init(includeContent: false)) {
            CarouselContentView(viewModel: viewModel)
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .if(viewModel.launchAnimation == .cardHighlight) {
            $0.zIndex(1)
        }
    }
    
}

// MARK: - CarouselContentView

/// The content within the scrollable area
private struct CarouselContentView: View {
    
    // MARK: Properties
    
    @Environment(\.observable) var observable
    
    typealias Constants = CarouselUtilities.Constants
    
    typealias MovieColumn = [ViewModel.MovieViewModel]
    typealias ViewModel = SwiftUIHomepageCarouselView.ViewModel
    let viewModel: ViewModel
    
    let movieColumns: [MovieColumn]
    
    @State private var slideIndex: Int = 0
    
    // MARK: Constructor
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        self.movieColumns = viewModel.data.transpose()
    }
    
    // MARK: Utility
    
    /// The visible columns
    private var visibleMovieColumns: ArraySlice<MovieColumn> {
        movieColumns.prefix(through: slideIndex)
    }
    
    private func cellHeight(width: CGFloat) -> CGFloat {
        CarouselUtilities.cellSize(forAvailableWidth: width, columns: CGFloat(viewModel.columns)).height
    }
    
    // MARK: View
    
    var body: some View {
        if let observable = observable {
            content(observable: observable)
        }
    }
    
    @ViewBuilder
    private func content(observable: ObservableScrollViewResult) -> some View {
        let cellSize = CarouselUtilities.cellSize(
            forAvailableWidth: observable.scrollViewFrame.size.width,
            columns: CGFloat(viewModel.columns)
        )
        let rows: [GridItem] = [.init(.fixed(cellSize.height))]
        
        LazyHGrid(rows: rows, spacing: 0) {
            ForEach(Array(movieColumns.enumerated()), id: \.offset) { index, column in
                SwiftUIHomepageColumnCell(cellSize: cellSize,
                                          column: column,
                                          performSlideAnimation: index >= slideIndex,
                                          performHighlight: index == 0 && viewModel.launchAnimation == .cardHighlight)
            }
        }
        .padding(.top, Constants.margins.top)
        .padding(.leading, Constants.margins.left)
        .padding(.trailing, Constants.margins.right)
        .padding(.bottom, Constants.margins.bottom)
        .onAppear {
            if case let .slideIn(delay) = viewModel.launchAnimation {
                // Slide Animation
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    // Start slide animation sequence
                    animationSlideIndex()
                }
            } else {
                // No Slide Animation
                slideIndex = movieColumns.count
            }
        }
    }
    
    // Recursively performs the slide in animation one column at a time
    private func animationSlideIndex() {
        guard slideIndex < (viewModel.columns + 1) else {
            // End Animation
            slideIndex = movieColumns.count
            return
        }
        let duration: TimeInterval = 0.5 / CGFloat(viewModel.columns + 1)
        let animation = Animation.interpolatingSpring(
            .init(response: duration, dampingRatio: 0.85),
            initialVelocity: 1
        )
        withAnimation(animation) {
            slideIndex += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: animationSlideIndex)
        }
    }
    
}

// MARK: - SwiftUIHomepageColumnCell

struct SwiftUIHomepageColumnCell: View {
    
    typealias Constants = CarouselUtilities.Constants
    
    let cellSize: CGSize
    fileprivate let column: CarouselContentView.MovieColumn
    let performSlideAnimation: Bool
    let performHighlight: Bool
    
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(spacing: Constants.rowSpacing) {
            ForEach(Array(column.enumerated()), id: \.offset) { (index, movie) in
                let trailingPadding = Constants.columnSpacing(
                    forIndex: 1,
                    performSlideAnimation: performSlideAnimation
                )
                SwiftUIHomepageCell(viewModel: movie,
                                    performHighlight: index == 0 && performHighlight)
                    .frame(width: cellSize.width, height: cellSize.height)
                    .padding(.trailing, trailingPadding)
            }
        }
        .if(performHighlight) {
            $0.zIndex(1)
        }
        .opacity(opacity)
        .observedVisibility { visible in
            // Fade in effect (on scroll)
            if visible {
                withAnimation(.linear(duration: 0.2)) {
                    opacity = 1
                }
            } else {
                opacity = 0
            }
        }
    }
}

// MARK: - SwiftUIHomepageCell

struct SwiftUIHomepageCell: View {
    
    typealias ViewModel = SwiftUIHomepageCarouselView.ViewModel.MovieViewModel
    let viewModel: ViewModel
    let performHighlight: Bool
    
    @State private var isZoomed = false
    @State private var didPerformZoom = false
    
    var body: some View {
        VStack {
            Image(uiImage: viewModel.movie.poster)
                .resizable()
                .overlay(alignment: .top) {
                    if viewModel.showTitle {
                        Text(viewModel.movie.name)
                            .foregroundStyle(.white)
                            .padding(.bottom, 32)
                    }
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .if(performHighlight, modifier: {
            $0.zoom(show: $isZoomed)
        })
        .onAppear(perform: {
            if performHighlight && !didPerformZoom {
                isZoomed = true
                didPerformZoom = true
                // Not ideal but we have to force a layout cycle before we can start the animation
                DispatchQueue.main.async {
                    withAnimation(.linear(duration: 0.2)) {
                        isZoomed = false
                    }
                }
            }
            
        })
    }
    
}

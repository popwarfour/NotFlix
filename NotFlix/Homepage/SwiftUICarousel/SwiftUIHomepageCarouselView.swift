//
//  SwiftUICarouselView.swift
//  NotFllix
//
//  Created by Anders on 3/14/24.
//

import SwiftUI

struct SwiftUIHomepageCarouselView: View {
    
    typealias ViewModel = HomepageCarouselViewModel
    let viewModel: ViewModel
    
    @State private var geometryReaderResult = GeometryReaderResult.empty()
//    @State private var performSlideAnimation = false
    
    var body: some View {
        ScrollView.observable(.horizontal, configuration: .init(includeContent: false)) {
            CarouselContentView(viewModel: viewModel)
        }
        .scrollIndicators(.hidden)
//        .onAppear() {
//            if case let .slideIn(delay) = viewModel.launchAnimation {
//                performSlideAnimation = true
//                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                    performSlideAnimation = viewModel.launchAnimation == .slideIn()
//                    let animation = Animation
////                        .interpolatingSpring(.init(response: 0.5, dampingRatio: 0.85),
////                                             initialVelocity: 1)
//                        .linear(duration: 5)
//                    withAnimation(animation) {
//                        performSlideAnimation = false
//                    }
//                }
//            }
//            
//        }
    }
    
}

private struct CarouselContentView: View {
    
    // MARK: Properties
    
    @Environment(\.observable) var observable
    
    typealias Constants = CarouselUtilities.Constants
    
    typealias MovieColumn = [ViewModel.MovieViewModel]
    typealias ViewModel = SwiftUIHomepageCarouselView.ViewModel
    let viewModel: ViewModel
    
    let movieColumns: [MovieColumn]
    
    @State private var slideIndex: Int = 0
    
//    var flattenedMovies: [ViewModel.MovieViewModel] {
//        viewModel
//            .data
//            .transpose()
//            .flatMap { $0 }
//    }
    
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
                VStack(spacing: Constants.rowSpacing) {
                    ForEach(column) { movie in
                        SwiftUIHomepageCell(viewModel: movie)
                            .frame(width: cellSize.width, height: cellSize.height)
                            .if(index < movieColumns.count - 1, modifier: {
                                let trailingPadding = Constants.columnSpacing(
                                    forIndex: index,
                                    performSlideAnimation: index >= slideIndex
                                )
                                $0.padding(.trailing, trailingPadding)
                            })
                    }
                }
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

struct SwiftUIHomepageCell: View {
    
    typealias ViewModel = SwiftUIHomepageCarouselView.ViewModel.MovieViewModel
    let viewModel: ViewModel
    
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack {
            Image(uiImage: viewModel.movie.poster)
                .resizable()
//                .overlay(alignment: .top) {
//                    if viewModel.showTitle {
//                        Text(viewModel.movie.name)
//                            .padding(.bottom, 32)
//                            .background(Color.red)
//                    }
//                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
//        .opacity(opacity)
//        .observedVisibility { visible in
//            if visible {
//                withAnimation(.linear(duration: 0.2)) {
//                    opacity = 1
//                }
//            } else {
//                opacity = 0
//            }
//        }
        
    }
    
}

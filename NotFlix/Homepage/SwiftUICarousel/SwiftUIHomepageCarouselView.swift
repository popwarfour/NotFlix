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
    @State private var performSlideAnimation = false
    
    var body: some View {
        ScrollView.observable(.horizontal, configuration: .init(includeContent: false)) {
            CarouselContentView(viewModel: viewModel,
                                performSlideAnimation: performSlideAnimation)
        }
        .scrollIndicators(.hidden)
        .onAppear() {
            if case let .slideIn(delay) = viewModel.launchAnimation {
                performSlideAnimation = true
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    performSlideAnimation = viewModel.launchAnimation == .slideIn()
                    let animation = Animation.interpolatingSpring(
                        .init(response: 0.5, dampingRatio: 0.85),
                        initialVelocity: 1
                    )
                    withAnimation(animation) {
                        performSlideAnimation = false
                    }
                }
            }
            
        }
    }
    
}

private struct CarouselContentView: View {
    
    @Environment(\.observable) var observable
    
    typealias Constants = CarouselUtilities.Constants
    
    typealias ViewModel = SwiftUIHomepageCarouselView.ViewModel
    let viewModel: ViewModel
    
    let performSlideAnimation: Bool
    
    var flattenedMovies: [ViewModel.MovieViewModel] {
        viewModel
            .data
            .transpose()
            .flatMap { $0 }
    }
    
    func cellHeight(width: CGFloat) -> CGFloat {
        CarouselUtilities.cellSize(forAvailableWidth: width, columns: CGFloat(viewModel.columns)).height
    }
    
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
        let rows: [GridItem] = viewModel.data.map { _ in .init(.fixed(cellSize.height)) }
        
        LazyHGrid(rows: rows, spacing: 0) {
            ForEach(Array(flattenedMovies.enumerated()), id: \.offset) { index, movie in
                SwiftUIHomepageCell(viewModel: movie, show: index == 0)
                    .frame(width: cellSize.width, height: cellSize.height)
                    .padding(
                        .trailing,
                        Constants.columnSpacing(
                            forIndex: 1,
                            performSlideAnimation: performSlideAnimation
                        )
                    )
            }
        }
        .padding(.leading, Constants.margins.left)
        .padding(.trailing, Constants.margins.right)
    }
    
}

struct SwiftUIHomepageCell: View {
    
    typealias ViewModel = SwiftUIHomepageCarouselView.ViewModel.MovieViewModel
    let viewModel: ViewModel
    let show: Bool
    
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack {
            Image(uiImage: viewModel.movie.poster)
                .resizable()
                .overlay(alignment: .top) {
                    if viewModel.showTitle {
                        Text(viewModel.movie.name)
                            .padding(.bottom, 32)
                            .background(Color.red)
                    }
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .opacity(opacity)
        .observedVisibility { visible in
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

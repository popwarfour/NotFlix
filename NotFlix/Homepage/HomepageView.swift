//
//  HomepageView.swift
//  DeleteMe
//
//  Created by Anders on 3/13/24.
//

import SwiftUI

struct HomepageView: View {
    
    private static let defaultContent: [HomepageCarouselViewController.ViewModel] = [
        .init(id: 0,
              title: "Top Choice",
              columns: 1,
              data: [HomepageCarouselViewController.ViewModel.MovieViewModel.random(count: 10)],
              launchAnimation: .cardHighlight),
        .init(id: 1,
              title: "You Might Also Like",
              columns: 4,
              data: [HomepageCarouselViewController.ViewModel.MovieViewModel.random(count: 20,
                                                                              showTitle: false)],
              launchAnimation: .slideIn(delay: 0.5)),
        .init(id: 2,
              title: "Your Friends Are Watching",
              columns: 2,
              data: [HomepageCarouselViewController.ViewModel.MovieViewModel.random(count: 10),
                     HomepageCarouselViewController.ViewModel.MovieViewModel.random(count: 10)],
              launchAnimation: .slideIn(delay: 0.5))
    ]
    
    enum Mode {
        case uiKit
        case swiftUI
    }
    let mode: Mode
    
    @State private var showContent = true//false
    
    var body: some View {
        if showContent {
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    ForEach(Self.defaultContent) { viewModel in
                        switch mode {
                        case .uiKit:
                            // Heading
                            HStack {
                                Text(viewModel.title)
                                    .font(.headline)
                                    .foregroundStyle(Color.white)
                                Spacer(minLength: 0)
                            }
                            .padding([.leading, .trailing, .top, .bottom], 16)
                            // Carousel
                            UIKitHomepageCarouselView(viewModel: viewModel)
                        case .swiftUI:
                            // Heading
                            HStack {
                                Text(viewModel.title)
                                    .font(.headline)
                                    .foregroundStyle(Color.white)
                                Spacer(minLength: 0)
                            }
                            .padding([.leading, .trailing, .top, .bottom], 16)
                            // Carousel
                            SwiftUIHomepageCarouselView(viewModel: viewModel)
                        }
                        
                    }
                }
            }
            .background(Color.black)
        } else {
            Color
                .black
                .ignoresSafeArea()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showContent = true
                    }
                }
        }
    }
    
}

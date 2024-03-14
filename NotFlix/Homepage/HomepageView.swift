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
//        .init(id: 1,
//              title: "You Might Also Like",
//              columns: 4,
//              data: [MyCarouselViewController.ViewModel.MovieViewModel.random(count: 20,
//                                                                              showTitle: false)],
//              launchAnimation: .slideIn(delay: 0.1)),
//        .init(id: 2,
//              title: "You Might Also Like",
//              columns: 4,
//              data: [MyCarouselViewController.ViewModel.MovieViewModel.random(count: 20,
//                                                                              showTitle: false)],
//              launchAnimation: .slideIn(delay: 0.2)),
//        .init(id: 3,
//              title: "You Might Also Like",
//              columns: 4,
//              data: [MyCarouselViewController.ViewModel.MovieViewModel.random(count: 20,
//                                                                              showTitle: false)],
//              launchAnimation: .slideIn(delay: 0.3)),
//        .init(id: 4,
//              title: "You Might Also Like",
//              columns: 4,
//              data: [MyCarouselViewController.ViewModel.MovieViewModel.random(count: 20,
//                                                                              showTitle: false)],
//              launchAnimation: .slideIn(delay: 0.4)),
//        .init(id: 5,
//              title: "You Might Also Like",
//              columns: 4,
//              data: [MyCarouselViewController.ViewModel.MovieViewModel.random(count: 20,
//                                                                              showTitle: false)],
//              launchAnimation: .slideIn(delay: 0.5)),
    ]
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                ForEach(Self.defaultContent) { viewModel in
                    HStack {
                        Text(viewModel.title)
                            .font(.headline)
                            .foregroundStyle(Color.white)
                        Spacer(minLength: 0)
                    }
                    .padding([.leading, .trailing, .top, .bottom], 16)
                    
                    HomepageCarouselView(viewModel: viewModel)
                }
            }
        }
        .background(Color.black)
    }
    
}

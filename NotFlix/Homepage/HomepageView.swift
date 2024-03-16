//
//  HomepageView.swift
//  DeleteMe
//
//  Created by Anders on 3/13/24.
//

import SwiftUI

struct HomepageView: View {
    
    private static let defaultContent: [HomepageCarouselViewController.ViewModel] = [
//        .init(id: 0,
//              title: "Top Choice",
//              columns: 1,
//              data: [HomepageCarouselViewController.ViewModel.MovieViewModel.random(count: 10)],
//              launchAnimation: .cardHighlight),
//        .init(id: 1,
//              title: "You Might Also Like",
//              columns: 4,
//              data: [HomepageCarouselViewController.ViewModel.MovieViewModel.random(count: 20,
//                                                                              showTitle: false)],
//              launchAnimation: .slideIn(delay: 0.5)),
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
    static let mode = Mode.uiKit
    
    let coordinateSpace = CoordinateSpace.named("Mine")
    
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
                    
//                    switch Self.mode {
//                    case .uiKit:
//                        UIKitHomepageCarouselView(viewModel: viewModel)
//                            .border(.blue, width: 1)
//                    case .swiftUI:
                        SwiftUIHomepageCarouselView(viewModel: viewModel)
                            .border(.red, width: 1)
//                    }
                    
                }
            }
        }
        .background(Color.black)
    }
    
}

//
//  HomepageCarouselViewModel.swift
//  NotFllix
//
//  Created by Anders on 3/14/24.
//

import Foundation

struct HomepageCarouselViewModel: Identifiable {
    let id: Int
    
    let title: String
    
    let columns: Int
    let data: [[MovieViewModel]]
    
    let launchAnimation: LaunchAnimation?
    
    init(id: Int,
         title: String,
         columns: Int,
         data: [[MovieViewModel]],
         launchAnimation: LaunchAnimation? = nil) {
        self.id = id
        self.title = title
        self.columns = columns
        self.data = data
        self.launchAnimation = launchAnimation
    }
    
    enum LaunchAnimation: Equatable {
        /// The cards in the carousel will slide in the from the right
        case slideIn(delay: CGFloat = 0)
        /// The first card in the carousel with perform a fade in animation
        case cardHighlight
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.slideIn, .slideIn): return true
            case (.cardHighlight, .cardHighlight): return true
            default: return false
            }
        }
    }
    
    struct MovieViewModel: Identifiable {
        let id = UUID()
        let showTitle: Bool
        let movie: Movie
        
        init(_ movie: Movie, showTitle: Bool = true) {
            self.movie = movie
            self.showTitle = showTitle
        }
        
        static func random(count: Int, showTitle: Bool = true) -> [Self] {
            let all = Movie.all
            
            return (0..<count)
                .map { _ in
                    let index = Int.random(in: 0..<all.count)
                    let movie = all[index]
                    return .init(movie, showTitle: showTitle)
                }
        }
        
    }
    
}

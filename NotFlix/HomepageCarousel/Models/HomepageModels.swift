//
//  HomepageModels.swift
//  DeleteMe
//
//  Created by Anders on 3/13/24.
//

import UIKit

// MARK: - Movie

struct Movie {
    let name: String
    let poster: UIImage
    
    static let all: [Movie] = [
        .init(name: "Abyss", poster: .init(named: "Abyss")!),
        .init(name: "Avatar", poster: .init(named: "Avatar")!),
        .init(name: "Inglorious Bastards", poster: .init(named: "Bastards")!),
        .init(name: "The Dark Knight Rises", poster: .init(named: "DarkKnight")!),
        .init(name: "ET", poster: .init(named: "ET")!),
        .init(name: "Godzilla", poster: .init(named: "Godzilla")!),
        .init(name: "Home Alone", poster: .init(named: "HomeAlone")!),
        .init(name: "Jurassic Park", poster: .init(named: "JurassicPark")!),
        .init(name: "Lokie", poster: .init(named: "Lokie")!),
        .init(name: "Step Brothers", poster: .init(named: "StepBrothers")!),
        .init(name: "Titans", poster: .init(named: "Titans")!),
        .init(name: "War of the Worlds", poster: .init(named: "WarWorlds")!)
    ]
}

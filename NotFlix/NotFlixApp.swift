//
//  DeleteMeApp.swift
//  DeleteMe
//
//  Created by Anders on 3/6/24.
//

import SwiftUI

@main
struct DeleteMeApp: App {
    
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                List {
                    NavigationLink("UIKit Version") {
                        HomepageView(mode: .uiKit)
                    }
                    NavigationLink("SwiftUI Version") {
                        HomepageView(mode: .swiftUI)
                    }
                }
                .onAppear() {
                    
//                    let array = stride(from: 0, through: 10, by: 1)
//                        .reduce(into: [Int](), { $0.append($1) })
//                    
                    let array = (0..<10).reduce(into: [Int](), { $0.append($1) })
                    var slice = array[0..<5]
                    _ = slice.removeFirst()
                    
                    
                    let pref = array.prefix(upTo: 5)
                    let pref2 = array[0..<5]
                    
                    let max = array.max(by: <)
                    let sorted = array.sorted(by: >).first
                    
                    let start = array.startIndex
                    let end = array.index(-1, offsetBy: 5, limitedBy: array.count - 1) ?? array.endIndex
                    let results = array[start...end]
                    
                    print(array)
                    print(results)
                    
                }
            }
        }
    }
    

}

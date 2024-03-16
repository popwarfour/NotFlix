//
//  Transpose.swift
//  NotFllix
//
//  Created by Anders on 3/16/24.
//

import Foundation

func performTranspose<T>(_ matrix: [[T]]) -> [[T]] {
    guard !matrix.isEmpty else { return matrix }
    
    let columnCount = matrix[0].count
    
    var result = [[T]](repeating: [T](), count: columnCount)
    
    for row in matrix {
        for (index, element) in row.enumerated() {
            result[index].append(element)
        }
    }
    
    return result
}


extension Array where Element: MutableCollection & RangeReplaceableCollection {
    
    func transpose() -> Self {
        
        guard !self.isEmpty else { return self }
        
        let columnCount = self[0].count
        
        var result = Self.init(repeating: Element(), count: columnCount)
        
        for row in self {
            for (index, element) in row.enumerated() {
                result[index].append(element)
            }
        }
        
        return result
        
    }
}

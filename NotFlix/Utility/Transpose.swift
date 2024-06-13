//
//  Transpose.swift
//  NotFllix
//
//  Created by Anders on 3/16/24.
//

import Foundation

extension Array where Element: MutableCollection & RangeReplaceableCollection {
    
    /// Performs a matrix trasposition
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

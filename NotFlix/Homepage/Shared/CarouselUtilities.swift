//
//  CarouselUtilities.swift
//  NotFllix
//
//  Created by Anders on 3/14/24.
//

import UIKit

enum CarouselUtilities {
    
    // MARK: - Constants
    
    enum Constants {
        static func height(forWidth width: CGFloat) -> CGFloat { width * 1.5 }
        
        static let rowSpacing: CGFloat = 32
        
        static var peek: CGFloat { columnSpacing * 2 }
        
        static let columnSpacing: CGFloat = 16
        static func columnSpacing(forIndex index: Int, performSlideAnimation: Bool) -> CGFloat {
            guard performSlideAnimation else { return columnSpacing }
            let columnSpacing = CGFloat(index + 1) * columnSpacing * 20
            return columnSpacing
        }
        
        static let margins = UIEdgeInsets(top: 0,
                                          left: 16,
                                          bottom: 0,
                                          right: 16)
    }
    
    // MARK: - Layout Utility Methods
    
    static func contentSize(forAvailableWidth availableWidth: CGFloat,
                            columns: CGFloat,
                            rows: [Int],
                            performSlideAnimation: Bool) -> CGSize {
        let contentFrame = cellFrames(forAvailableWidth: availableWidth,
                                      columns: columns,
                                      rows: rows,
                                      performSlideAnimation: performSlideAnimation)
            .flatMap { $0 }
            .reduce(CGRect.zero, { $0.union($1) })
        
        return .init(width: contentFrame.width + Constants.margins.right,
                     height: contentFrame.height + Constants.margins.bottom)
    }
    
    static func cellFrames(forAvailableWidth availableWidth: CGFloat,
                           columns: CGFloat,
                           rows: [Int],
                           performSlideAnimation: Bool) -> [[CGRect]] {
        
        // Compute Column Width
        let cellSize = CarouselUtilities.cellSize(
            forAvailableWidth: availableWidth,
            columns: columns
        )
        
        // Compute Attributes
        var lastY: CGFloat = Constants.margins.top
        var lastX: CGFloat = Constants.margins.left
        
        var frames = [[CGRect]]()
        for row in rows {
            var rowsArray = [CGRect]()
            for column in 0..<row {
                let cellFrame = CGRect(
                    origin: .init(x: lastX, y: lastY),
                    size: cellSize
                )
                rowsArray.append(cellFrame)
                
                // Prepare next column
                lastX += cellFrame.width
                if column < row - 1 {
                    lastX += Constants.columnSpacing(forIndex: row, performSlideAnimation: performSlideAnimation)
                }
            }
            frames.append(rowsArray)
            
            // Prepare next row
            lastX = Constants.margins.left
            lastY += Constants.rowSpacing + cellSize.height
        }
        
        return frames
    }
    
    static func cellSize(forAvailableWidth availableWidth: CGFloat,
                         columns: CGFloat) -> CGSize {
        // Spacing
        let totalRowSpacing = columns * Constants.columnSpacing
        let totalMargin = Constants.margins.left 
        let totalSpacing = totalRowSpacing + totalMargin + Constants.peek
        // Cell Dimensions
        let cellWidth = (availableWidth - totalSpacing) / columns
        let cellHeight = Constants.height(forWidth: cellWidth)
        return .init(
            width: max(0, cellWidth),
            height: max(0, cellHeight)
        )
    }
    
}

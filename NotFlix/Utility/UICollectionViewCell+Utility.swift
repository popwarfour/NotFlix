//
//  UICollectionViewCell+Utility.swift
//  DeleteMe
//
//  Created by Anders on 3/13/24.
//

import UIKit

extension UICollectionView {
    
    /// Registeres a cell type using the standard identifier
    func register(cell: UICollectionViewCell.Type) {
        register(cell, forCellWithReuseIdentifier: cell.reuseIdentifier)
    }
    
    /// Dequeues a cell type using the standard identifier
    func dequeueReusableCell<T: UICollectionViewCell>(cell: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: cell.reuseIdentifier, for: indexPath) as! T
    }
    
}

extension UICollectionViewCell {
    
    /// The standard identifier
    static var reuseIdentifier: String {
        return self.description()
    }
    
}

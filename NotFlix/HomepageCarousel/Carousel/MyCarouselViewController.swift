//
//  MyCarouselViewController.swift
//  DeleteMe
//
//  Created by Anders on 3/7/24.
//

import UIKit
import SwiftUI

/*
 An experimental carousel built using UIKit with a SwiftUI compatibility layer
 */

// MARK: - View Representable

struct CarouselView: UIViewControllerRepresentable {
    
    let viewModel: MyCarouselViewController.ViewModel
    
    func makeUIViewController(context: Context) -> MyCarouselViewController {
        .init(viewModel: viewModel)
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiViewController: MyCarouselViewController, context: Context) -> CGSize? {
        
        let size = CGSize(width: proposal.replacingUnspecifiedDimensions().width,
                          height: uiViewController.preferredContentSize.height)
        
        print("SIZE THAT FITS - \(size)")
        return size
        
    }
    
    func updateUIViewController(_ uiViewController: MyCarouselViewController, context: Context) {
        // no-op
    }
    
}

// MARK: - View Controller

final class MyCarouselViewController: UICollectionViewController {
    
    // MARK: - Properties
    
    // MARK: View Model
    
    struct ViewModel: Identifiable {
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
        
        struct MovieViewModel {
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
    private let viewModel: ViewModel
    
    // MARK: Layout
    
    private let layout: CarouselLayout
    
    // MARK: Highlight Animation
    
    private var highlightAnimationStorage: HighlightAnimationStorage?
    private struct HighlightAnimationStorage {
        let mock: HomepageCellView
        let widthConstriant: NSLayoutConstraint
        let heightConstraint: NSLayoutConstraint
        let finalSize: CGSize
        
        func cleanUp() {
            mock.removeFromSuperview()
        }
    }
    
    // MARK: - Constructors
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        self.layout = CarouselLayout(columns: viewModel.columns,
                                     performSlideAnimation: viewModel.launchAnimation == .slideIn())
        super.init(collectionViewLayout: self.layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        print("VIEW DID LOAD - BEFORE")
        super.viewDidLoad()
        
        collectionView.backgroundColor = .clear
        
        print("VIEW DID LOAD - AFTER")
        collectionView.register(cell: HomepageCell.self)
    }
    
    override func viewDidLayoutSubviews() {
        print("VIEW DID LAYOUT SUBVIEWS - BEFORE")
        super.viewDidLayoutSubviews()
        
        print("VIEW DID LAYOUT SUBVIEWS - AFTER")
        preferredContentSize = .init(width: view.bounds.width,
                                     height: layout.cache.contentSize.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewWillAppearForHighlightAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewDidAppearForHighlightAnimation()
        viewDidAppearForSlideInAnimation()
    }
    
    // MARK: Launch Animation
    
    private func viewDidAppearForSlideInAnimation() {
        guard case let .slideIn(delay) = viewModel.launchAnimation else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.layout.performSlideAnimationIfNeeded()
        }
    }
    
    // MARK:  Highlight Animation
    
    private func viewWillAppearForHighlightAnimation() {
        guard viewModel.launchAnimation == .cardHighlight else { return }
        guard let cellViewModel = viewModel.data.first?.first else { return }
        
        // Get Global Position
        let cell = self.collectionView.dequeueReusableCell(cell: HomepageCell.self, for: .init(row: 0, section: 0))
        let cellMidPoint = CGPoint(x: cell.frame.midX,
                                   y: cell.frame.midY)
        
        // Create Mock
        let mock = HomepageCellView(frame: .zero)
        mock.setup(viewModel: cellViewModel)
        self.view.addSubview(mock)
        mock.alpha = 0.75
        mock.translatesAutoresizingMaskIntoConstraints = false
        let heightConstraint = mock.heightAnchor.constraint(equalToConstant: cell.bounds.height * 2)
        let widthConstraint = mock.widthAnchor.constraint(equalToConstant: cell.bounds.width * 2)
        NSLayoutConstraint.activate([
            mock.centerXAnchor.constraint(equalTo: self.view.leadingAnchor,
                                          constant: cellMidPoint.x),
            mock.centerYAnchor.constraint(equalTo: self.view.topAnchor,
                                          constant: cellMidPoint.y),
            heightConstraint,
            widthConstraint
        ])
        
        // Save Mock
        self.highlightAnimationStorage = .init(
            mock: mock,
            widthConstriant: widthConstraint,
            heightConstraint: heightConstraint,
            finalSize: cell.bounds.size
        )
    }
    
    private func viewDidAppearForHighlightAnimation() {
        guard viewModel.launchAnimation == .cardHighlight else { return }
        guard let storage = highlightAnimationStorage else { return }
        // Animate Mock
        view.bringSubviewToFront(storage.mock)
        UIView.animate(withDuration: 0.2) {
            storage.widthConstriant.constant = storage.finalSize.width
            storage.heightConstraint.constant = storage.finalSize.height
            storage.mock.alpha = 1
            storage.mock.setNeedsLayout()
            storage.mock.layoutIfNeeded()
        } completion: { finished in
            // Remove Mock
            guard finished else { return }
            storage.cleanUp()
            self.highlightAnimationStorage = nil
        }
    }
    
    // MARK: - Delegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: Do something
    }

    // MARK: - Data Source
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.data.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.data[section].count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(cell: HomepageCell.self, for: indexPath)
        
        let viewModel = viewModel.data[indexPath.section][indexPath.row]
        cell.setup(viewModel: viewModel)
    
        // Start Faded Out
        cell.contentView.alpha = 0
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Fade In On Display - Simulated Network delay
        UIView.animate(withDuration: 0.20) {
            cell.contentView.alpha = 1
        }
    }
    
}

// MARK: - Layout

private final class CarouselLayout: UICollectionViewLayout {
    
    // MARK: Properties
    
    private let columns: CGFloat
    private(set) var cache = Cache()
    
    /// Are we performing the slide animation
    private var performSlideAnimation = false
    
    final class Cache: RangeReplaceableCollection {
        
        typealias CacheArray = [UICollectionViewLayoutAttributes]
        
        var cache = CacheArray()
        var contentSize: CGSize = .zero
        
        func reset() {
            cache.removeAll()
            contentSize = .zero
        }
        
        typealias Element = CacheArray.Element
        typealias Index = CacheArray.Index
        
        var startIndex: Index { return cache.startIndex }
        var endIndex: Index { return cache.endIndex }

        subscript(index: Index) -> Iterator.Element {
            get { return cache[index] }
        }
        
        subscript(indexPath: IndexPath) -> Iterator.Element? {
            get { cache.first(where: { $0.indexPath == indexPath }) }
        }

        func index(after i: Index) -> Index {
            return cache.index(after: i)
        }
        
        func replaceSubrange<C>(_ subrange: Range<CacheArray.Index>,
                                with newElements: C) where C : Collection, CacheArray.Element == C.Element {
            cache.replaceSubrange(subrange, with: newElements)
        }
        
    }
    
    private enum Constants {
        static func height(forWidth width: CGFloat) -> CGFloat { width * 1.5 }
        
        static let rowSpacing: CGFloat = 32
        
        static var peek: CGFloat { columnSpacing * 2}
        
        static let columnSpacing: CGFloat = 16
        static func columnSpacing(for index: Int, performSlideAnimation: Bool) -> CGFloat {
            guard performSlideAnimation else { return columnSpacing }
            return CGFloat(index + 1) * columnSpacing * 20
        }
        
        static let margins = UIEdgeInsets(top: 0,
                                          left: 16,
                                          bottom: 0,
                                          right: 16)
    }
    
    // MARK: Setup
    
    init(columns: Int, performSlideAnimation: Bool) {
        self.columns = CGFloat(columns)
        self.performSlideAnimation = performSlideAnimation
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Slide animation
    
    /// Executes the slide animation if needed
    func performSlideAnimationIfNeeded() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1) {
            self.collectionView?.performBatchUpdates({
                self.performSlideAnimation = false
                self.collectionView?.reloadData()
            })
        }
    }
    
    // MARK: Overrides
    
    override var collectionViewContentSize: CGSize {
        return cache.contentSize
    }
    
    override func prepare() {
        super.prepare()
        
        computeCache()
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        cache.reset()
    }
    
    /// Computes layout for new bounds
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.cache
    }
    
    /// Layout for specific index
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath]
    }
    
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }
    
    // MARK: Computation
    
    private func computeCache() {
        guard let collectionView else {
            assertionFailure()
            return
        }
        
        // Compute Column Width
        let availableWidth = collectionView.bounds.width
        let totalSpacing = (columns + 1) * Constants.columnSpacing
        let cellWidth = (availableWidth - totalSpacing - Constants.peek) / columns
        let cellHeight = Constants.height(forWidth: cellWidth)
        
        // Compute Attributes
        var lastY: CGFloat = Constants.margins.top
        var lastX: CGFloat = Constants.margins.left
        
        for section in 0..<collectionView.numberOfSections {
            for row in 0..<collectionView.numberOfItems(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                
                let cellFrame = CGRect(
                    x: lastX,
                    y: lastY,
                    width: cellWidth,
                    height: cellHeight
                )
                let item = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                item.frame = cellFrame
                
                cache.append(item)
                
                // Prepare next column
                lastX += cellWidth
                if row < collectionView.numberOfItems(inSection: section) - 1 {
                    lastX += Constants.columnSpacing(for: row, performSlideAnimation: performSlideAnimation)
                }
            }
            
            // Prepare next row
            if section < collectionView.numberOfSections - 1 {
                lastX = Constants.margins.left
                lastY += Constants.rowSpacing + cellHeight
            }
        }
        
     
        // Content Size
        cache.contentSize = .init(width: lastX + Constants.margins.right,
                                  height: ceil(lastY + cellHeight + Constants.margins.bottom))
        
        print("CACHE UPDATED - \(cache.contentSize)")
    }
    
}


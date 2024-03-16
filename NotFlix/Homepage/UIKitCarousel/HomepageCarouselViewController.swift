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

struct UIKitHomepageCarouselView: UIViewControllerRepresentable {
    
    let viewModel: HomepageCarouselViewController.ViewModel
    
    func makeUIViewController(context: Context) -> HomepageCarouselViewController {
        .init(viewModel: viewModel)
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiViewController: HomepageCarouselViewController, context: Context) -> CGSize? {
        CGSize(width: proposal.replacingUnspecifiedDimensions().width,
               height: uiViewController.preferredContentSize.height)
    }
    
    func updateUIViewController(_ uiViewController: HomepageCarouselViewController, context: Context) {
        // no-op
    }
    
}

// MARK: - View Controller

final class HomepageCarouselViewController: UICollectionViewController {
    
    // MARK: - Properties
    
    typealias ViewModel = HomepageCarouselViewModel
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
        super.viewDidLoad()
        collectionView.backgroundColor = .clear
        collectionView.register(cell: HomepageCell.self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
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
    
    typealias Constants = CarouselUtilities.Constants
    
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
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0) {
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
        // Update Cache
        let rows = stride(from: 0, to: collectionView.numberOfSections, by: 1)
            .map { collectionView.numberOfItems(inSection: $0) }
        let cellFrames = CarouselUtilities.cellFrames(
            forAvailableWidth: collectionView.bounds.width,
            columns: columns,
            rows: rows,
            performSlideAnimation: performSlideAnimation
        )
        
        var largestX: CGFloat = 0
        var largestY: CGFloat = 0
        cellFrames
            .enumerated()
            .forEach { (sectionIndex, section) in
                section
                    .enumerated()
                    .forEach { (rowIndex, cellFrame) in
                        let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                        let item = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                        item.frame = cellFrame
                        cache.append(item)
                        
                        if cellFrame.maxX > largestX {
                            largestX = cellFrame.maxX
                        }
                        if cellFrame.maxY > largestY {
                            largestY = cellFrame.maxY
                        }
                    }
            }
     
        // Content Size
        cache.contentSize = CarouselUtilities.contentSize(
            forAvailableWidth: collectionView.bounds.width,
            columns: columns,
            rows: rows,
            performSlideAnimation: performSlideAnimation
        )
    }
    
}


//
//  HomepageCell.swift
//  DeleteMe
//
//  Created by Anders on 3/13/24.
//

import UIKit

// MARK: - HomepageCell

final class HomepageCell: UICollectionViewCell {
    
    typealias ViewModel = MyCarouselViewController.ViewModel.MovieViewModel
    private let homepageViewCellView = HomepageCellView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(homepageViewCellView)
        homepageViewCellView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            homepageViewCellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            homepageViewCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            homepageViewCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            homepageViewCellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(viewModel: ViewModel) {
        homepageViewCellView.setup(viewModel: viewModel)
    }
    
}

// MARK: - Homepage Cell View

final class HomepageCellView: UIView, Pressable {
    
    private let label = UILabel(frame: .zero)
    private let imageView = UIImageView(frame: .zero)
    
    private let effectsView = UIVisualEffectView(frame: .zero)
    private let gradientLayer = CAGradientLayer()
    
    var viewModel: ViewModel?
    
    private enum Constants {
        static let stackSpacing: CGFloat = 8
    }
    
    typealias ViewModel = MyCarouselViewController.ViewModel.MovieViewModel
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if effectsView.bounds == .zero || gradientLayer.frame != effectsView.bounds {
            effectsView.layoutIfNeeded()
            gradientLayer.frame = effectsView.bounds
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.pressable(isPressed: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.pressable(isPressed: false)
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        // Background
        backgroundColor = .clear
        backgroundColor = .clear
        
        // Container
        let container = UIView(frame: .zero)
        addSubview(container)
        container.layer.cornerRadius = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        container.clipsToBounds = true
        container.layer.masksToBounds = true
        
        // Content - Image
        container.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        // Content - Label Blur
        container.addSubview(effectsView)
        effectsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            effectsView.topAnchor.constraint(equalTo: container.topAnchor),
            effectsView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            effectsView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        effectsView.effect = UIBlurEffect(style: .systemChromeMaterialDark)
        
        // Create CAGradientLayer
        gradientLayer.locations = [NSNumber(value: 0), NSNumber(value: 0.65), NSNumber(value: 1)]
        gradientLayer.colors = [UIColor.black.cgColor,
                                UIColor.black.cgColor,
                                UIColor.clear.cgColor]
        effectsView.layer.mask = gradientLayer
        
        // Content - Label
        container.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: effectsView.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: effectsView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: effectsView.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: effectsView.bottomAnchor, constant: -32)
        ])
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .extraLargeTitle)
        label.textColor = UIColor.white
        label.numberOfLines = 1
        label.minimumScaleFactor = 0.5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(viewModel: ViewModel) {
        self.viewModel = viewModel
        // Title
        if viewModel.showTitle {
            effectsView.isHidden = false
            label.text = viewModel.movie.name
        } else {
            effectsView.isHidden = true
        }
        // Image
        imageView.image = viewModel.movie.poster
    }
    
}

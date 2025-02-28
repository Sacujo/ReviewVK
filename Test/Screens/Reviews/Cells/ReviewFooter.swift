//
//  ReviewFooter.swift
//  Test
//
//  Created by Igor Guryan on 28.02.2025.
//

import UIKit

final class ReviewFooterView: UIView {
    private var totalReviewsLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//MARK: - Internal

extension ReviewFooterView {
    
    func configure(with count: Int) {
        totalReviewsLabel.attributedText = "\(count) отзывов".attributed(font: .reviewCount, color: .reviewCount )
    }
}

//MARK: - Private
private extension ReviewFooterView {
    
    func setupView() {
        backgroundColor = .systemBackground
        setupLabel()
    }
    
    func setupLabel() {
        addSubview(totalReviewsLabel)
        
        totalReviewsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            totalReviewsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            totalReviewsLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }    
}

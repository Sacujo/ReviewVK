//
//  PhotoCell.swift
//  Test
//
//  Created by Igor Guryan on 01.03.2025.
//

import UIKit

final class PhotoCell: UICollectionViewCell {
    
    static let reuseId = String(describing: PhotoCell.self)
    
    var imageView = UIImageView()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    
    private func setupCell() {
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "avatar")
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
    }
    
    func configure(with photoUrl: String) {
        imageView.imageFromServerURL(photoUrl, placeHolder: UIImage(named: "avatar"))
    }
    
    
}

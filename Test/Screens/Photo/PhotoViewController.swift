//
//  PhotoViewController.swift
//  Test
//
//  Created by Igor Guryan on 02.03.2025.
//

import UIKit

final class PhotoViewController: UIViewController {
    
    var photoUrl: String!
    
    private var imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillLayoutSubviews() {
        imageView.frame = view.bounds
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        imageView.contentMode = .scaleAspectFit
        imageView.imageFromServerURL(photoUrl, placeHolder: nil)
        
        view.addSubview(imageView)
    }
    
    
}

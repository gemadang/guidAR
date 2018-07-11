//
//  ImageViewController.swift
//  guidAR-final
//
//  Created by Geri Elise Madanguit on 5/6/18.
//  Copyright © 2018 GeriMadanguit. All rights reserved.
//

import Foundation
import UIKit

class ImageViewController : UIViewController{
    var image: UIImage?
    
    lazy var foundImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = image
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    return imageView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(foundImageView)
        foundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        foundImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24).isActive = true
        foundImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        foundImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
}

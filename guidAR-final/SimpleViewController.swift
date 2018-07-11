//
//  SimpleViewController.swift
//  guidAR-final
//
//  Created by Geri Elise Madanguit on 5/5/18.
//  Copyright © 2018 GeriMadanguit. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SimpleViewController: UIViewController {
    let inputTextView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var visionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 175, g: 15, b: 15)
        button.setTitle("Find", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleVision), for: .touchUpInside)
        
        return button
    }()
    
    let objectTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Object"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    @objc func handleVision() {
        //enter into Database
        
        
        
        let visionController = VisionViewController()
        visionController.searchKey = objectTextField.text!
        navigationController?.pushViewController(visionController, animated: true)
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 175, g: 15, b: 15)
        
        view.addSubview(inputTextView)
        view.addSubview(visionButton)
        
        setupInputTextView()
        setupVisionButton()
    }
    
    var inputViewHeightAnchor: NSLayoutConstraint?
    var objectTextFieldHeightAnchor: NSLayoutConstraint?
    
    func setupInputTextView() {
        //need x, y, width, height constraints
        inputTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputTextView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -70).isActive = true
        inputTextView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputViewHeightAnchor = inputTextView.heightAnchor.constraint(equalToConstant: 150)
        inputViewHeightAnchor?.isActive = true
        
        inputTextView.addSubview(objectTextField)
       
        //need x, y, width, height constraints
        objectTextField.leftAnchor.constraint(equalTo: inputTextView.leftAnchor, constant: 12).isActive = true
        objectTextField.topAnchor.constraint(equalTo: inputTextView.topAnchor).isActive = true
        objectTextField.widthAnchor.constraint(equalTo: inputTextView.widthAnchor).isActive = true
        objectTextFieldHeightAnchor = objectTextField.heightAnchor.constraint(equalTo: inputTextView.heightAnchor, multiplier: 1/3)
        objectTextFieldHeightAnchor?.isActive = true
    }
    
    func setupVisionButton() {
        //need x, y, width, height constraints
        visionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        visionButton.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant: 12).isActive = true
        visionButton.widthAnchor.constraint(equalTo: inputTextView.widthAnchor).isActive = true
        visionButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}

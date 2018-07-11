//
//  DetailController.swift
//  MovieListApp
//
//  Created by Geri Elise Madanguit on 3/26/18.
//  Copyright © 2018 GeriMadanguit. All rights reserved.
//

import UIKit
import Firebase

class DetailController: UIViewController {
    var history : History?
    
    let header:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let overview:UITextView = {
        let label = UITextView()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let iconImageView:UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let detailView: DetailViews = {
        let detailView = DetailViews()
        detailView.translatesAutoresizingMaskIntoConstraints = false
        return detailView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor(r: 175, g: 15, b: 15)
        setupNavBar()
        setupViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        
        // fetch User info! Set up Navigation Bar!
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                //                self.navigationItem.title = dictionary["name"] as? String
                
                let user = User(dictionary: dictionary)
                //                self.setupNavBarWithUser(user)
            }
            
        }, withCancel: nil)
    }
    
    func setupNavBar(){
        /*
         navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
         navigationItem.title = "WOOOOO Movies"
         
         */
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(addReview))
    }
    
    @objc func addReview(){
    }

    
    func setupViews(){
/*
        view.addSubview(detailView) //collectionview
        detailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        detailView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        detailView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.4).isActive = true
        detailView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1.0).isActive = true
    */
        //detailView.setUpViews()
        
        view.addSubview(header) //title
        header.text = history?.label
        header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        header.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.1).isActive = true
        header.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8).isActive = true
        
        view.addSubview(overview)
        overview.text = history?.score
        overview.topAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        overview.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        overview.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.3).isActive = true
        overview.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8).isActive = true
        
        view.addSubview(iconImageView)
        iconImageView.downloadImageUsingCacheWithLink((history?.image)!)
        iconImageView.topAnchor.constraint(equalTo: overview.bottomAnchor, constant: 10).isActive = true
        iconImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 2).isActive = true //leading = left, trailing = tright
        iconImageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
    }
    
}


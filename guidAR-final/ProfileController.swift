//
//  ProfileController.swift
//  guidAR
//
//  Created by Geri Elise Madanguit on 4/16/18.
//  Copyright © 2018 GeriMadanguit. All rights reserved.
//

import UIKit
import Firebase

class ProfileController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var searchHistoryController: SearchHistoryController?
    var name: String?
    var email: String?
    var profileurl: String?
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let fullnameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Full Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let fullnameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let companyTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Company"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let companySeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let workTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Type of Work"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let workSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let locationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Location"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        // Tapping Action!!!
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    lazy var logout_button:UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 175, g: 175, b: 255)
        button.setTitle("Logout", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleLogout() {
        // Sign-out!!!
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        // Show Login Screen Modally!!!
        let loginController = LoginController()
        loginController.profileController = self
        ///FIX THIS LATER^^^^
        present(loginController, animated: true, completion: nil)
    }
    
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        // show Image Picker!!!! (Modally)
        present(picker, animated: true, completion: nil)
    }
    
    // UIImagePickerController Delegates!!!
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleUpdate() {
        
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        //successfully authenticated user
        
        // upload profile image
        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
        
        // Compress Image into JPEG type
        //self.registerUserIntoDatabaseWithUID(uid)
        if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
            
            _ = storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    print("Error when uploading profile image")
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                self.profileurl = metadata.downloadURL()?.absoluteString
                self.registerUserIntoDatabaseWithUID(uid)
            }
        }
        
    }
    
    fileprivate func registerUserIntoDatabaseWithUID(_ uid: String) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        
        let values = ["name": nameTextField.text, "email": email, "fullname": fullnameTextField.text, "company": companyTextField.text, "work": workTextField.text, "location": locationTextField.text, "profileurl": profileurl] as [String : AnyObject]
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err ?? "")
                return
            }
            
            //self.myTopListViewController?.fetchUserAndSetupNavBarTitle()
            self.searchHistoryController?.fetchUserAndSetupNavBarTitle()
            self.searchHistoryController?.navigationController?.popViewController(animated: true)
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 175, g: 15, b: 15)
        
        view.addSubview(inputsContainerView)
        view.addSubview(profileImageView)
        view.addSubview(logout_button)
        
        setupNavBar()
        setupInputsContainerView()
        setupProfileImageView()
        setupLogoutButton()
        
        if let name = name {
            nameTextField.text = name
        }
    }
    
    func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        // Read User information from DB
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.navigationItem.title = dictionary["name"] as? String
                
                let user = User(dictionary: dictionary)
                self.setupProfileWithUser(user)
            }
            
        }, withCancel: nil)
    }
    
    func setupNavBar(){
        if let name = name {
            navigationItem.title = name
        }
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleUpdate))
    }
    
    func setupProfileWithUser(_ user: User) {
        name = user.name
        if let url = user.profileurl {
            profileImageView.downloadImageUsingCacheWithLink(url)
        }
        if let name = user.name {
            nameTextField.text = name
        }
        if let fullname = user.fullname {
            fullnameTextField.text = fullname
        }
        if let company = user.company {
            companyTextField.text = company
        }
        if let work = user.work {
            workTextField.text = work
        }
        if let location = user.location {
            locationTextField.text = location
        }
    }
    
    func setupLogoutButton(){
        //need x, y, width, height constraints
        logout_button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logout_button.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        logout_button.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        logout_button.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupProfileImageView() {
        //need x, y, width, height constraints
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func setupInputsContainerView() {
        //need x, y, width, height constraints
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 12) .isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeparatorView)
        inputsContainerView.addSubview(fullnameTextField)
        inputsContainerView.addSubview(fullnameSeparatorView)
        inputsContainerView.addSubview(companyTextField)
        inputsContainerView.addSubview(companySeparatorView)
        inputsContainerView.addSubview(workTextField)
        inputsContainerView.addSubview(workSeparatorView)
        inputsContainerView.addSubview(locationTextField)
        
        
        //need x, y, width, height constraints
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5).isActive = true
        
        //need x, y, width, height constraints
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        fullnameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        fullnameTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        fullnameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        fullnameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5).isActive = true
        
        //need x, y, width, height constraints
        fullnameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        fullnameSeparatorView.topAnchor.constraint(equalTo: fullnameTextField.bottomAnchor).isActive = true
        fullnameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        fullnameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        companyTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        companyTextField.topAnchor.constraint(equalTo: fullnameTextField.bottomAnchor).isActive = true
        companyTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        companyTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5).isActive = true
        
        //need x, y, width, height constraints
        companySeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        companySeparatorView.topAnchor.constraint(equalTo: companyTextField.bottomAnchor).isActive = true
        companySeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        companySeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        workTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        workTextField.topAnchor.constraint(equalTo: companyTextField.bottomAnchor).isActive = true
        workTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        workTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5).isActive = true
        
        //need x, y, width, height constraints
        workSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        workSeparatorView.topAnchor.constraint(equalTo: workTextField.bottomAnchor).isActive = true
        workSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        workSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        locationTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        locationTextField.topAnchor.constraint(equalTo: workTextField.bottomAnchor).isActive = true
        locationTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        locationTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5).isActive = true
    }
    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}


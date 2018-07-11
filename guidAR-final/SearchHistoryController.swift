//
//  SearchHistoryController.swift
//  guidAR
//
//  Created by Geri Elise Madanguit on 3/26/18.
//  Copyright © 2018 GeriMadanguit. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, AnyObject>()
import Firebase

class SearchHistoryController: UITableViewController {
    
    var historyList = [History]()
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor(r: 175, g: 15, b: 15)
        setupNavBar()
        checkIfUserIsLoggedIn()

        navigationItem.title = "Search History"
        tableView.register(ListCell.self, forCellReuseIdentifier: "cell_id")
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func setupNavBar(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Vision", style: .plain, target: self, action: #selector(handleVision))
        navigationItem.title = "Search History"
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: #selector(viewProfile))
    }
    
    @objc func handleVision() {
        let enterobject = SimpleViewController()
        navigationController?.pushViewController(enterobject, animated: true)
    }
    
    @objc func handleLogout() {
        // Sign-out!!!
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        // Show Login Screen Modally!!!
        let loginController = LoginController()
        loginController.searchHistoryController = self
        present(loginController, animated: true, completion: nil)
    }
    
    @objc func viewProfile(){
        let profileController = ProfileController()

        profileController.fetchUserProfile()
        navigationController?.pushViewController(profileController, animated: true)
    }
    
    func checkIfUserIsLoggedIn() {
        // if not sign in, display login screen!!!
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
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
                self.setupNavBarWithUser(user)
            }
            
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(_ user: User) {
        
        fetch_history()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        self.tableView.reloadData()

    }

    func fetch_history(){
        guard let uid = Auth.auth().currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        // Read User information from DB
        let ref = Database.database().reference()
        ref.child("users").child(uid).child("search_history").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                //self.navigationItem.title = dictionary["name"] as? String
                print(dictionary)
                let history = History()
                history.label = dictionary["label"] as! String
                history.score = dictionary["score"] as! String
                history.image = dictionary["image"] as! String
                self.historyList.append(history)
                //self.setupProfileWithUser(user)
                DispatchQueue.main.async {
                    self.tableView.reloadData()}
            }
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //edit
        /*
        if let number = results?.movies.count {
            return number
        }
         */
        return historyList.count
    }
    
    func showDetailOfMovie(history: History){
        let detailController = DetailController()
        detailController.history = history
        navigationController?.pushViewController(detailController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()

            historyList.remove(at: indexPath.row)


            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showDetailOfMovie(history: historyList[indexPath.row])
        
        /*
        if let history = historyList[indexPath.row]{
            self.showDetailOfHistory(history: history)
        }
         */
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //edit
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_id", for: indexPath) as! ListCell
            let posterlink = historyList[indexPath.row].image
            cell.iconImageView.downloadImageUsingCacheWithLink(posterlink!)
            cell.review_number.text = historyList[indexPath.row].score
            cell.textLabel?.text = historyList[indexPath.row].label
            cell.backgroundColor = UIColor(r: 175, g: 15, b: 15)
            return cell
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}

class ListCell: UITableViewCell{
    
    let iconImageView:UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let review_number:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func setupViews(){
        contentView.addSubview(iconImageView)
        iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2).isActive = true //leading = left, trailing = tright
        iconImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        contentView.addSubview(review_number)
        review_number.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        review_number.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -100).isActive = true
        review_number.heightAnchor.constraint(equalToConstant: 30).isActive = true
        review_number.widthAnchor.constraint(equalToConstant: 80).isActive = true
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 70, y: 40, width: textLabel!.frame.width, height: 30)
    }
}
extension UIImageView {
    func downloadImageUsingCacheWithLink(_ urlLink: String){
        self.image = nil
        if urlLink.isEmpty {
            return
        }
        // check cache first
        if let cachedImage = imageCache.object(forKey: urlLink as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        // otherwise, download
        let url = URL(string: urlLink)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if let err = error {
                print(err)
                return
            }
            DispatchQueue.main.async {
                if let newImage = UIImage(data: data!) {
                    imageCache.setObject(newImage, forKey: urlLink as NSString)
                    self.image = newImage
                }
            }
        }).resume()
    }
}


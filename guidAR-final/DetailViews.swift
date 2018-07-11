//
//  DetailViews.swift
//  guidAR
//
//  Created by Geri Elise Madanguit on 4/10/18.
//  Copyright © 2018 GeriMadanguit. All rights reserved.
//

import Foundation
import UIKit

class DetailViews : UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var image_results : MovieImages?
    var movieDetail: MovieData?
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.scrollDirection = .horizontal
        return cv
    }()
    
    
    var movie: MovieInfo? {
        didSet{
            let id = movie?.id
            let images_link = "https://api.themoviedb.org/3/movie/\(id!)/images?api_key=eafa1ac83fa7dccea6df7b0d6e1c4f57"
            let image_url = URL(string: images_link)
            
            URLSession.shared.dataTask(with: image_url!){ (data, response, err) in
                if err == nil {
                    guard let jsondata = data else { return }
                    do {
                        self.image_results = try JSONDecoder().decode(MovieImages.self, from: jsondata)
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }catch {
                        print("JSON DOWNLOADING ERROR!")
                    }
                }
                }.resume()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews(){
        collectionView.dataSource = self
        collectionView.delegate = self
        
        addSubview(collectionView)
        //
        //        collectionView.backgroundColor = UIColor.black
        //        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        //        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        //        collectionView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        //        collectionView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        addConstraintsWithFormat("V:|[v0]|", views: collectionView)
        collectionView.register(PosterCell.self, forCellWithReuseIdentifier: "postercellid")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = image_results?.posters.count {
            return count
        }
        else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("in here")
        if let poster_image = image_results?.posters[indexPath.item] {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postercellid", for: indexPath) as! PosterCell
            let poster_path = "https://image.tmdb.org/t/p/w185" + (poster_image.filePath)!
            print("look here" + poster_path)
            cell.poster_image.downloadImageUsingCacheWithLink(poster_path)
            //cell.backgroundView = cell.poster_image
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // cell size is entire page
        //return CGSize(width: view.frame.width, height: view.frame.height)
        
        return CGSize(width: 150, height: 100)
    }
    
}
class PosterCell: UICollectionViewCell{
    override init(frame: CGRect) {
        super .init(frame: frame)
        setUpCellViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init hasn't been initializes")
    }
    
    let poster_image : UIImageView = {
        let picture = UIImageView()
        return picture
    }()
    
    func setUpCellViews(){
        addSubview(poster_image)
        addConstraintsWithFormat("H:|[v0]|", views: poster_image)
        addConstraintsWithFormat("V:|[v0]|", views: poster_image)
        
    }
}

extension UIView {
    func addConstraintsWithFormat(_ format: String, views: UIView...){
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
}


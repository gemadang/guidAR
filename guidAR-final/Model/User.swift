//
//  User.swift
//  guidAR
//
//  Created by Geri Elise Madanguit on 4/16/18.
//  Copyright © 2018 GeriMadanguit. All rights reserved.
//

import UIKit

class History: NSObject {
    var label: String?
    var score: String?
    var image: String?
}

class User: NSObject {
    var id: String?
    var name: String?
    var email: String?
    var fullname: String?
    var company: String?
    var work: String?
    var location: String?
    var profileurl: String?
    
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.fullname = dictionary["fullname"] as? String
        self.company = dictionary["company"] as? String
        self.work = dictionary["work"] as? String
        self.location = dictionary["location"] as? String
        self.profileurl = dictionary["profileurl"] as? String
    }
}

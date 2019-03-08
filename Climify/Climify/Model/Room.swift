//
//  Room.swift
//  Climify
//
//  Created by Christian Hjelmslund on 08/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class Room: NSObject {
    var id: String
    var name: String
    var location: String
    
    init (id: String, name: String, location: String){
        self.id = id
        self.name = name
        self.location = location
    }
    
    convenience override init(){
        self.init(id: "", name: "", location: "")
    }
}

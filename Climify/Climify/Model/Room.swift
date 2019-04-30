//
//  Room.swift
//  Climify
//
//  Created by Christian Hjelmslund on 08/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

struct Room {
    var id: String
    var name: String
    
    init (id: String, name: String){
        self.id = id
        self.name = name
    }
    
    init(){
        self.init(id: "", name: "")
    }
}

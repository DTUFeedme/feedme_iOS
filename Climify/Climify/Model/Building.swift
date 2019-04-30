//
//  Building.swift
//  Climify
//
//  Created by Christian Hjelmslund on 04/04/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

struct Building {
    var id: String
    var name: String
    var rooms: [Room]?
    
    init (id: String, name: String, rooms: [Room]?){
        self.id = id
        self.name = name
        self.rooms = rooms
    }
    
    init(){
        self.init(id: "", name: "", rooms: [Room.init()])
    }
}

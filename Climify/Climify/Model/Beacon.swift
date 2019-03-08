//
//  Beacon.swift
//  Climify
//
//  Created by Christian Hjelmslund on 08/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class Beacon: NSObject {
    var uuid: String
    var name: String
    var room: Room
    var id: String
    var location: String
    
    init (id: String, uuid: String, name: String, room: Room, location: String){
        self.id = id
        self.location = location
        self.uuid = uuid
        self.name = name
        self.room = room
    }
}

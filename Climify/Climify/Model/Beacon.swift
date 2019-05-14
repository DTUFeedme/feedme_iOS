//
//  Beacon.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 08/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class Beacon {
    var uuid: String
    var name: String
    var building: Building
    var id: String
    
    init (id: String, uuid: String, name: String, building: Building){
        self.id = id
        self.uuid = uuid
        self.name = name
        self.building = building
    }
}

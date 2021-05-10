//
//  Beacon.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 08/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class Beacon: Decodable {
    var uuid: String
    var name: String
    // var _id: String
    
    init (uuid: String, name: String){
        // self._id = _id
        self.uuid = uuid
        self.name = name
    }
}

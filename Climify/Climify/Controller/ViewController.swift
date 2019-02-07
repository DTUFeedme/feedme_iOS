//
//  ViewController.swift
//  Climify
//
//  Created by Christian Hjelmslund on 07/02/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var bluetoothService: BluetoothService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bluetoothService = BluetoothService()
        bluetoothService.initBluetooth()
    }
}


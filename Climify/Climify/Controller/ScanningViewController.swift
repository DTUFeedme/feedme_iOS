//
//  ScanningViewController.swift
//  Climify
//
//  Created by Christian Hjelmslund on 30/04/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class ScanningViewController: UIViewController {

    private var coreLocation = CoreLocation()
    
    @IBOutlet weak var roomname: UITextField!
    
    @IBAction func startScanning(_ sender: Any) {
        coreLocation.isMappingRoom = true
        coreLocation.startLocating()
    }
    
    @IBAction func testYourLocation(_ sender: Any) {
        coreLocation.startLocating()
    }
    @IBAction func stopScanning(_ sender: Any) {
        coreLocation.postRoom(roomname: roomname.text!)
        coreLocation.stopTimerAddToSignalMap()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

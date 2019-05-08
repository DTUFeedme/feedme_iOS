//
//  ScanningViewController.swift
//  Climify
//
//  Created by Christian Hjelmslund on 30/04/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class ScanningVC: UIViewController {

    @IBOutlet weak var provideRoomLabel: UILabel!
    private var isScanning = false
    @IBOutlet weak var roomname: UITextField!
    @IBOutlet weak var scanningButton: UIButton!
    
    @IBAction func startScanning(_ sender: Any) {
        if isScanning {
            CoreLocation.sharedInstance.postRoom(roomname: roomname.text!)
            CoreLocation.sharedInstance.stopTimerAddToSignalMap()
            CoreLocation.sharedInstance.isMappingRoom = false
            scanningButton.setTitleColor(.myGreen(), for: .normal)
            scanningButton.layer.borderColor = .myGreen()
            scanningButton.layer.removeAllAnimations()
            scanningButton.setTitle("Start Scanning", for: .normal)
            isScanning = !isScanning
        } else {
            if (roomname.text?.isEmpty)! {
                provideRoomLabel.text = "Please give a room name"
            } else {
                view.endEditing(true)
                provideRoomLabel.text = ""
                scanningButton.pulseInfite()
                scanningButton.setTitleColor(.myRed(), for: .normal)
                scanningButton.layer.borderColor = .myRed()
                CoreLocation.sharedInstance.isMappingRoom = true
                CoreLocation.sharedInstance.startLocating()
                scanningButton.setTitle("Stop Scanning", for: .normal)
                isScanning = !isScanning
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func tapped(_ sender: Any) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scanningButton.setTitleColor(.myGreen(), for: .normal)
        scanningButton.layer.cornerRadius = 0.5 * scanningButton.bounds.size.width
        scanningButton.clipsToBounds = true
        scanningButton.backgroundColor = .clear
        scanningButton.layer.borderColor = .myGreen()
        scanningButton.layer.borderWidth = 3
        scanningButton.layer.shadowOpacity = 1
        scanningButton.layer.shadowOffset = CGSize.zero
        scanningButton.layer.shadowRadius = 10
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

//
//  ScanningViewController.swift
//  Climify
//
//  Created by Christian Hjelmslund on 30/04/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class ScanningVC: UIViewController {
    
    @IBOutlet weak var roomname: UITextField!
    @IBOutlet weak var scanningButton: UIButton!
    @IBOutlet weak var provideRoomLabel: UILabel!
    @IBOutlet weak var message: UILabel!
    var climifyApi: ClimifyAPI!
    var locationEstimator: LocationEstimator!
    private var isScanning = false
  
    override func viewDidLoad() {
        climifyApi = appDelegate.climifyApi
        locationEstimator = appDelegate.locationEstimator
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
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
    
    @IBAction func startScanning(_ sender: Any) {
        if isScanning {
            locationEstimator.postRoom(roomname: roomname.text!) { error in
                if error == nil {
                    self.message.text = "Succesfully saved room dimensions"
                    self.roomname.text = nil
                } else {
                    self.message.text = "Something went wrong. Please check your internet connection"
                }
                self.locationEstimator.stopTimerAddToSignalMap()
                self.locationEstimator.isMappingRoom = false
            }
       
            scanningButton.setTitleColor(.myGreen(), for: .normal)
            scanningButton.layer.borderColor = .myGreen()
            scanningButton.layer.removeAllAnimations()
            scanningButton.setTitle("Start Scanning", for: .normal)
            isScanning = !isScanning
        } else {
            if (roomname.text?.isEmpty)! {
                provideRoomLabel.text = "Please give a room name"
            } else {
                self.message.text = ""
                view.endEditing(true)
                provideRoomLabel.text = ""
                scanningButton.pulseInfite()
                scanningButton.setTitleColor(.myRed(), for: .normal)
                scanningButton.layer.borderColor = .myRed()
                locationEstimator.isMappingRoom = true
                locationEstimator.initTimerAddToSignalMap()
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

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

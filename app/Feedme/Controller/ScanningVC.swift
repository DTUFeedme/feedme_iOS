//
//  ScanningViewController.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 30/04/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class ScanningVC: UIViewController {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var roomnametextfield: UITextField!
    @IBOutlet weak var scanningButton: UIButton!
    @IBOutlet weak var provideRoomLabel: UILabel!
    @IBOutlet weak var message: UILabel!
    var feedmeNS: FeedmeNetworkService!
    var locationEstimator: LocationEstimator!
    var chosenRoom: String!
    var chosenRoomId: String!
    var buildingId: String!
    private var isScanning = false
  
    @IBAction func pickRoom(_ sender: Any) {
        let sb = UIStoryboard(name: "Data", bundle: nil)
        let roomChooserVC = sb.instantiateViewController(withIdentifier: "roomchooser") as! RoomChooserVC
        
        roomChooserVC.didPickRoom = true
        roomChooserVC.manuallyChangedRoomDelegate = self
        
        present(roomChooserVC, animated: true, completion: nil)

    }
    
    @IBAction func showInfo(_ sender: Any) {
        if infoLabel.isHidden {
            infoLabel.isHidden = false
            message.text = ""
        } else {
            infoLabel.isHidden = true
        }
    }
    override func viewDidLoad() {
        feedmeNS = appDelegate.feedmeNS
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
    }
    
    @IBAction func startScanning(_ sender: Any) {
        if isScanning {
            infoLabel.isHidden = true
            
            chosenRoom = nil
            scanningButton.setTitleColor(.myGreen(), for: .normal)
            scanningButton.layer.borderColor = .myGreen()
            scanningButton.layer.removeAllAnimations()
            scanningButton.setTitle("Start Scanning", for: .normal)
            isScanning = !isScanning
            self.locationEstimator.scanningRoomId = ""
            self.locationEstimator.isMappingRoom = false
            self.message.text = "Succesfully saved room with dimensions"
            self.roomnametextfield.text = nil
            self.locationEstimator.initTimerfetchRoom()
            
        } else if (roomnametextfield.text?.isEmpty)! {
            provideRoomLabel.shake()
            provideRoomLabel.text = "Please give a room name" 
        } else {
            if chosenRoom != nil {
                print("hey")
                guard let buildingId = locationEstimator.buildingId else {
                    self.message.text = "Something went wrong. Please check your internet connection or make sure that the beacons are nearby"
                    return
                }
                locationEstimator.pushSignalMap(roomid: chosenRoomId!, buildingId: buildingId) { room in
                    if room == nil {
                        self.message.text = "Something went wrong. Please check your internet connection or make sure that the beacons are nearby"
                    } else {
                        self.message.text = "Succesfully added new room dimensions"
                        self.roomnametextfield.text = nil
                    }
                    self.locationEstimator.stopTimerAddToSignalMap()
                    self.locationEstimator.isMappingRoom = false
                }
            } else {
                locationEstimator.postRoom(roomname: roomnametextfield.text!) { error in
                    if error == nil {
                        print("hey")
                        self.message.text = ""
                        self.view.endEditing(true)
                        self.provideRoomLabel.text = ""
                        self.scanningButton.pulseInfite()
                        self.scanningButton.setTitleColor(.myRed(), for: .normal)
                        self.scanningButton.layer.borderColor = .myRed()
                        self.locationEstimator.isMappingRoom = true
                        self.locationEstimator.initTimerAddToSignalMap()
                        self.locationEstimator.stopTimerfetchRoom()
                        self.scanningButton.setTitle("Stop Scanning", for: .normal)
                        self.isScanning = !self.isScanning
//                        self.message.text = "Succesfully saved room with dimensions"
//                        self.roomnametextfield.text = nil
                    } else {
                        self.message.text = "Something went wrong. Please check your internet connection or make sure that the beacons are nearby"
                    }
                    
                    
                }
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

extension ScanningVC: ManuallyChangedRoomProtocol {
    func roomchanged(roomname: String, roomid: String) {
        chosenRoom = roomname
        chosenRoomId = roomid
        roomnametextfield.text = chosenRoom
    }
}

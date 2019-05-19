//
//  RoomChooserVC.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 26/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class RoomChooserVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var choosenRoomLabel: UILabel!
    @IBOutlet weak var buildingPickerView: UIPickerView!
    @IBOutlet weak var saveChanges: UIButton!
    
    private var buildings: [Building] = []
    private var selectedBuildingIndex = 0
    private var selectedRoomIndex = 0
    
    var feedmeNS: FeedmeNetworkService!
    var manuallyChangedRoomDelegate: ManuallyChangedRoomProtocol!
    var currentRoom = ""
    
    @IBAction func hidePopUp(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        if let name = buildings[safe: selectedBuildingIndex]?.rooms?[safe: selectedRoomIndex]?.name, let roomid = buildings[safe: selectedBuildingIndex]?.rooms?[safe: selectedRoomIndex]?.id {
            manuallyChangedRoomDelegate.roomchanged(roomname: name, roomid: roomid)
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedmeNS = appDelegate.feedmeNS
        setupUI()
        feedmeNS.fetchBuildings() { buildings, error in
            if error == nil {
                self.buildings = buildings!
                self.buildingPickerView.delegate = self
                self.buildingPickerView.dataSource = self
                self.buildingPickerView.reloadAllComponents()
            } else {
                if (FeedmeNetworkService.Connectivity.isConnectedToInternet){
                    self.choosenRoomLabel.text = "Please give some feedback."
                } else {
                    self.choosenRoomLabel.text = "No internet connection"
                }
                self.saveChanges.setTitle("close", for: .normal)
            }
        }
    }
    
    func setupUI(){
        if currentRoom == "" {
            choosenRoomLabel.text = "couldn't estimate your location 😱"
        } else {
            choosenRoomLabel.text = "you are in \(currentRoom)"
        }
        buildingPickerView.layer.shadowColor = UIColor.black.cgColor
        buildingPickerView.layer.shadowOpacity = 5
        buildingPickerView.layer.shadowOffset = CGSize.zero
        buildingPickerView.layer.shadowRadius = 15
        saveChanges.backgroundColor = .clear
        saveChanges.layer.cornerRadius = 20
        saveChanges.layer.borderWidth = 2
        saveChanges.layer.borderColor = .myCyan()
        
        bgView.layer.cornerRadius = 15
        bgView.layer.masksToBounds = true
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let w = pickerView.frame.size.width
        return component == 0 ? (1 / 2.0) * w : (1 / 2.0) * w
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return buildings.count
        } else {
            if let rooms = buildings[selectedBuildingIndex].rooms {
                return rooms.count
            } else {
                return 0
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return buildings[row].name
        } else {
            if let room = buildings[selectedBuildingIndex].rooms?[row] {
                return room.name
            } else {
                return ""
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedBuildingIndex = row
        } else {
            selectedRoomIndex = row
        }
        pickerView.reloadAllComponents()
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
        return 50.0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label: UILabel
        if let view = view as? UILabel {
            label = view
        } else {
           label = UILabel(frame: CGRect(x: 0, y: 0, width: pickerView.frame.width/2, height: 400))
        }
        label.textColor = .myCyan()
        label.textAlignment = .left
        label.font = label.font.withSize(22)
//        
        if component == 0 {
            label.text =  buildings[row].name
        } else {
            if let roomname = buildings[selectedBuildingIndex].rooms?[row] {
                label.text = roomname.name
            }
        }
        
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}



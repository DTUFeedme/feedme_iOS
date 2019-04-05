//
//  RoomChooserController.swift
//  Climify
//
//  Created by Christian Hjelmslund on 26/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit

class RoomChooserController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var choosenRoomLabel: UILabel!
    @IBOutlet weak var buildingPickerView: UIPickerView!
    let networkService = NetworkService()
    var delegate: ManuallyChangedRoom!
    var buildings: [Building] = []//[Building(id: nil, name: "test", rooms: [Room(id: "", name: "", location: " ")])]
    var selectedBuildingIndex = 0
    var selectedRoomIndex = 0
    var chosenRoom = ""
    
    @IBAction func doneButton(_ sender: Any) {
        delegate.roomchanged(roomname: buildings[selectedBuildingIndex].rooms[selectedRoomIndex].name, roomid: buildings[selectedBuildingIndex].rooms[selectedRoomIndex].id)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        choosenRoomLabel.text = "you are in \(chosenRoom)"
        bgView.layer.cornerRadius = 15
        bgView.layer.masksToBounds = true
        
        networkService.getBuildings() { buildings, statusCode in
            if statusCode == HTTPCode.SUCCES {
                self.buildings = buildings
                self.buildingPickerView.delegate = self
                self.buildingPickerView.dataSource = self
                self.buildingPickerView.reloadAllComponents()
            } else {
                print(statusCode)
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let w = pickerView.frame.size.width
        return component == 0 ? (2 / 3.0) * w : (1 / 3.0) * w
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return buildings.count
        } else {
            return buildings[selectedBuildingIndex].rooms.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return buildings[row].name
        } else {
            return buildings[selectedBuildingIndex].rooms[row].name
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
        label.textAlignment = .center
        label.font = label.font.withSize(20)
//        
        if component == 0 {
            label.text =  buildings[row].name
        } else {
            label.text =  buildings[selectedBuildingIndex].rooms[row].name
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

protocol ManuallyChangedRoom {
    func roomchanged(roomname: String, roomid: String)
}



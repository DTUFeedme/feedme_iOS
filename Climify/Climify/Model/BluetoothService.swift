//
//  BluetoothService.swift
//  Climify
//
//  Created by Christian Hjelmslund on 07/02/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothService: NSObject {
    
    var manager: CBCentralManager!
    //let uuid = CBUUID(string: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")
    
    func initBluetooth(){
        manager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension BluetoothService: CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            manager.scanForPeripherals(withServices: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        
        
        
        
         if (peripheral.name == "Kontakt"){
            print("RSSI: ",RSSI)
            
            print("UUID: ",peripheral.identifier.uuidString)
            print("PERIPHERAL: ",peripheral.identifier)
            //print(peripheral.identifier.uuid)
            

        }
        //print(peripheral)
        
        
        
    }

}



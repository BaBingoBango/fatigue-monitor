//
//  ViewController.swift
//  Originally provided by E4 sample code
//  Handles E4 wristband delegate
//

import UIKit
import SwiftUI

class ViewController: UITableViewController {
    weak var delegate: ViewControllerDelegate?
    
    private var devices: [EmpaticaDeviceManager] = []
    private var serialNum: String = ""
    
    private var user_id: Int = -1
    
    private var heartRates: [Int] = []
    private var lastUpdateTime: Double = 0
    

    private var max_heart_rate: Int = 180
    private var awc_exp: Int = 0
    private var userInfoLoader = UserInfoLoader()
    
    /// OBSOLETE
    /// Replaced by `userInfoLoader`
    //    private var rest_heart_rate: Int = 60
    //    private var hrr_cp: Int = 16
    //    private var awc_tot: Int = 200
    //    private var k_value: Int = 1
    

    
    init(delegate: ViewControllerDelegate/*, user_id: Int, max_heart_rate: Int, rest_heart_rate: Int, hrr_cp: Int, awc_tot: Int, k_value: Int*/) {
        super.init(style: .plain)
        self.delegate = delegate
        
        FirebaseManager.connect()
        FirebaseManager.loadUserInfo(loader: userInfoLoader)
        
        @AppStorage("userAge") var userAge: Int = 0
        max_heart_rate = 208 - Int(0.7 * Double(userAge))
        
        print("viewcontroller user_id: \(user_id)")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var allDisconnected : Bool {
        return self.devices.reduce(true) { (value, device) -> Bool in
            value && device.deviceStatus == kDeviceStatusDisconnected
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
//        self.tableView.backgroundColor = UIColor(named: "BackgroundColorGray")
        self.tableView.isScrollEnabled = false

        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            EmpaticaAPI.authenticate(withAPIKey: Config.EMPATICA_API_KEY) { (status, message) in
                if status {
                    // "Authenticated"
                    DispatchQueue.main.async {
                        self.discover()
                    }
                }
            }
        }
    }
    
    private func discover() {
        EmpaticaAPI.discoverDevices(with: self)
    }
    
    private func disconnect(device: EmpaticaDeviceManager) {
        if device.deviceStatus == kDeviceStatusConnected {
            device.disconnect()
        }
        else if device.deviceStatus == kDeviceStatusConnecting {
            device.cancelConnection()
        }
    }
    
    private func connect(device: EmpaticaDeviceManager) {
        device.connect(with: self)
    }
    
    private func updateValue(device : EmpaticaDeviceManager, battery : Int = -1) {
        
        if let row = self.devices.firstIndex(of: device) {
            
            DispatchQueue.main.async {
                
                for cell in self.tableView.visibleCells {
                    
                    if let cell = cell as? DeviceTableViewCell {
                        
                        if cell.device == device {
                            
                            let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0))
                            
                            if !device.allowed {
                                cell?.detailTextLabel?.text = "NOT ALLOWED"
                                cell?.detailTextLabel?.textColor = UIColor.orange
                            }
                            else if battery >= 0 { // with battery
                                cell?.detailTextLabel?.text = "\(self.deviceStatusDisplay(status: device.deviceStatus)) • \(battery)%"
                                
                                if device.deviceStatus == kDeviceStatusConnected {
                                    cell?.detailTextLabel?.textColor = battery > 20 ? UIColor(Color(red: 52/255, green: 178/255, blue: 51/255)) : UIColor.orange
                                }
                                else {
                                    cell?.detailTextLabel?.textColor = UIColor.gray
                                }
                                
                            }
                            else { // without battery
                                cell?.detailTextLabel?.text = "\(self.deviceStatusDisplay(status: device.deviceStatus))"
                                
                                if device.deviceStatus == kDeviceStatusConnected {
                                    cell?.detailTextLabel?.textColor = UIColor(Color(red: 52/255, green: 178/255, blue: 51/255))
                                }
                                else {
                                    cell?.detailTextLabel?.textColor = UIColor.gray
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func deviceStatusDisplay(status : DeviceStatus) -> String {
        
        switch status {
            
        case kDeviceStatusDisconnected:
            return "Disconnected"
        case kDeviceStatusConnecting:
            return "Connecting..."
        case kDeviceStatusConnected:
            return "Connected"
        case kDeviceStatusFailedToConnect:
            return "Failed to connect"
        case kDeviceStatusDisconnecting:
            return "Disconnecting..."
        default:
            return "Unknown"
        }
    }
    
    private func restartDiscovery() {
        print("restartDiscovery")
        guard EmpaticaAPI.status() == kBLEStatusReady else { return }
        if self.allDisconnected {
            print("restartDiscovery • allDisconnected")
            self.discover()
        }
    }
}

protocol ViewControllerDelegate: AnyObject {
    func updateHeartRate(_ viewController: ViewController, heartRate: Int)
    func updateFatigueLevel(_ viewController: ViewController, fatigueLevel: Int)
    func updateDeviceStatus(_ viewController: ViewController, deviceConnected: Bool)
}


// utilities
extension ViewController {
    
    // POST
    func uploadHeartRate(heartRate: Int, timestamp: Double) {
        FirebaseManager.connect()
        FirebaseManager.uploadHeartRate(heartRate: heartRate, timestamp: timestamp)
    }
    
    // POST
    func uploadFatigueLevel(fatigueLevel: Int, timestamp: Double) {
        FirebaseManager.connect()
        FirebaseManager.uploadFatigueLevel(fatigueLevel: fatigueLevel, timestamp: timestamp)
    }
    
    func getAverageHeartRate() -> Int {
        if (heartRates.isEmpty) {
            return 0
        } else {
            let sum = heartRates.reduce(0, +)
            return sum / heartRates.count
        }
    }
    
    /// Assesses fatigue, updates the UI, and uploads the data on the database.
    func assessFatigue() {
        print("\(Date().timeIntervalSince1970) start assessing \(self.heartRates.count) heart rate data")
        self.lastUpdateTime = Date().timeIntervalSince1970
        
        // calculate HRR
        let avgHR = getAverageHeartRate()
        if (avgHR == 0) {
            return
        }
        let HRR = Int(Double(avgHR - userInfoLoader.rest_hr) / Double(self.max_heart_rate - userInfoLoader.rest_hr) * 100)
        print("avgHR = \(avgHR)")
        print("HRR = \(HRR)")
        
        // assess fatigue
        self.awc_exp = max(self.awc_exp + userInfoLoader.k_value * (HRR - userInfoLoader.hr_reserve_cp), 0)
        let fatigue = Int(Double(self.awc_exp) / Double(userInfoLoader.total_awc) * 100)
        print("fatigue = \(fatigue)")
        
        // update UI
        print("fatigue updated")
        delegate?.updateHeartRate(self, heartRate: avgHR)
        delegate?.updateFatigueLevel(self, fatigueLevel: fatigue)
        
        // upload to server
        uploadFatigueLevel(fatigueLevel: fatigue, timestamp: Date().timeIntervalSince1970)
        
        // reset
        self.heartRates = []
        
        // Upload to highlights?
        let fatigueWarningThreshold: Int = 0
        if fatigue > fatigueWarningThreshold {
            uploadFatigueHighlight(min(fatigue, 100))
        }
    }
    
    /// Uploads fatigue warning to Firebase and sends notifications to group members.
    /// Subject to rate limiting (no two notifications within X minutes)
    func uploadFatigueHighlight(_ fatigueLevel: Int) {
        // Rate limiting
        let maxFrequency: Double = 3 * 60; // in minutes
        let lastSent = UserDefaults.standard.double(forKey: "lastFatigueWarningSent") // default: 0.0
        let now = Date().timeIntervalSince1970
        if now < lastSent + (maxFrequency * 60) { // rate limited
            return
        }
        else { // ok
            UserDefaults.standard.set(now, forKey: "lastFatigueWarningSent")
        }
        
        let firstName = UserDefaults.standard.string(forKey: "userFirstName") ?? "ERROR"
        let groupId = UserDefaults.standard.string(forKey: "userGroupId") ?? "ERROR"
        NodeServer.sendFatigueWarning(firstName: firstName, fatigueLevel: fatigueLevel, groupId: groupId)
        FirebaseManager.uploadFatigueWarning(fatigueLevel)
    }
}

extension ViewController: EmpaticaDelegate {
    
    func didDiscoverDevices(_ devices: [Any]!) {
        
        print("didDiscoverDevices")
        
        if self.allDisconnected {
            
            print("didDiscoverDevices • allDisconnected")
            
            self.devices.removeAll()
            
            self.devices.append(contentsOf: devices as! [EmpaticaDeviceManager])
            
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
                
                if self.allDisconnected {
                    EmpaticaAPI.discoverDevices(with: self)
                }
            }
        }
    }
    
    func didUpdate(_ status: BLEStatus) {
        
        switch status {
        case kBLEStatusReady:
            print("[didUpdate] status \(status.rawValue) • kBLEStatusReady")
            break
        case kBLEStatusScanning:
            print("[didUpdate] status \(status.rawValue) • kBLEStatusScanning")
            break
        case kBLEStatusNotAvailable:
            print("[didUpdate] status \(status.rawValue) • kBLEStatusNotAvailable")
            break
        default:
            print("[didUpdate] status \(status.rawValue)")
        }
    }
}

extension ViewController: EmpaticaDeviceDelegate {
    
    /// Called when the app receives a temperature data from the wristband.
    func didReceiveTemperature(_ temp: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        
        //        let strDate = ts2date(timestamp: timestamp)
        //        print("\(device.serialNumber!) \(strDate) TEMP { \(temp) }")
        //        delegate?.updateFatigueLevel(self, fatigueLevel: Int(temp))
    }
    
    /// Called when the app receives an IBI data from the wristband.
    func didReceiveIBI(_ ibi: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        // unrealistic heart rate?
        let heartRate = Int(60 / ibi)
        if (heartRate > max_heart_rate) {
            return
        }
        
        let avgHR = getAverageHeartRate()
        if (avgHR == 0 || (avgHR != 0 && abs(heartRate - avgHR) < 30)) {
            heartRates.append(heartRate)
//            delegate?.updateHeartRate(self, heartRate: heartRate) // UI
            uploadHeartRate(heartRate: heartRate, timestamp: timestamp)
        }
        
        // check time interval
        if (timestamp - self.lastUpdateTime > 60) {
            assessFatigue()
        }
        print("\(device.serialNumber!) \(ts2date(timestamp: timestamp)) IBI { \(ibi) }")
    }

    /// ???
    func didUpdate( _ status: DeviceStatus, forDevice device: EmpaticaDeviceManager!) {
        
        self.updateValue(device: device)
        
        delegate?.updateDeviceStatus(self,
                                     deviceConnected: status == kDeviceStatusConnected)
        
        switch status {
            
        case kDeviceStatusDisconnected:
            print("[didUpdate] Disconnected \(device.serialNumber!).")
            self.restartDiscovery()
            break
            
        case kDeviceStatusConnecting:
            print("[didUpdate] Connecting \(device.serialNumber!).")
            break
            
        case kDeviceStatusConnected:
            print("[didUpdate] Connected \(device.serialNumber!).")
            self.lastUpdateTime = Date().timeIntervalSince1970 + 10
            print("init lastUpdateTime to \(self.lastUpdateTime).")
            break
            
        case kDeviceStatusFailedToConnect:
            print("[didUpdate] Failed to connect \(device.serialNumber!).")
            self.restartDiscovery()
            break
            
        case kDeviceStatusDisconnecting:
            print("[didUpdate] Disconnecting \(device.serialNumber!).")
            break
            
        default:
            break
            
        }
    }
    
    /// Called when the app receives battery level data from the wristband.
    func didReceiveBatteryLevel(_ level: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        let percentage = Int((level * 100).rounded(.up))
        self.updateValue(device: device, battery: percentage)
    }
}

// handle touch selection
extension ViewController {
    // on touch
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        EmpaticaAPI.cancelDiscovery()
        
        let device = self.devices[indexPath.row]
        
        if device.deviceStatus == kDeviceStatusConnected || device.deviceStatus == kDeviceStatusConnecting {
            self.disconnect(device: device)
        }
        else if !device.isFaulty && device.allowed {
            self.connect(device: device)
        }
        
        self.updateValue(device: device)
    }
}

extension ViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.devices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let device = self.devices[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "device") as? DeviceTableViewCell ?? DeviceTableViewCell(device: device)
        cell.device = device
        
        // text
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        cell.textLabel?.text = "E4 \(device.serialNumber!)"
        cell.alpha = device.isFaulty || !device.allowed ? 0.2 : 1.0
        
        return cell
    }
}

class DeviceTableViewCell : UITableViewCell {
    
    var device : EmpaticaDeviceManager
    
    var testLabel: UILabel!
    
    init(device: EmpaticaDeviceManager) {
        
        self.device = device
        super.init(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "device")
        
        // wristband image
        imageView!.image = UIImage(named: "E4_wristband_wc")
        imageView!.frame = CGRectMake(0, 0, 80, 80)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}

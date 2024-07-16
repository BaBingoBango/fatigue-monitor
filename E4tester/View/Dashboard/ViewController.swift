//
//  ViewController.swift
//  Originally provided by E4 sample code
//  Handles E4 wristband delegate
//

import UIKit
import SwiftUI
import UserNotifications
import FirebaseAuth
import FirebaseFirestore

class ViewController: UITableViewController {
    weak var delegate: ViewControllerDelegate?
    
    private var devices: [EmpaticaDeviceManager] = []
    private var serialNum: String = ""
    
    private var user_id: Int = -1
    
    /// Used to calculate fatigue level
    private var heartRates: [Int] = []
    
    /// For recording purposes
    private var heartRateMap: [String: Int] = [:]
    private var skinTempMap: [String: Float] = [:]
    private var GSRmap: [String: Float] = [:]
    private var BVPmap: [String: Float] = [:]
    
    private var lastUpdateTime: Double = 0
    

    private var max_heart_rate: Int = 180
    private var awc_exp: Double = 0
    private var userInfoLoader = UserInfoLoader()
    
    var modelData: ModelData?
    
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
    
    /// Calculates predicted heat strain by pre-processing collected data and using the Core ML model.
    func assessHeatStrain() {
        print("""
        🔥 Assessing heat strain based on
            · \(heartRateMap.count) HR measurements
            · \(skinTempMap.count) temperature measurements
            · \(GSRmap.count) GSR measurements
            · \(BVPmap.count) BVP measurements
        """)
        
        let urlString = "https://process-data-7bul3hscwq-uc.a.run.app"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var json: [String: Any] = [:]
        
        json["BVP"] = Array(BVPmap.values)
        json["BVP_sampling_rate"] = 64
        
        json["EDA"] = Array(GSRmap.values)
        json["EDA_sampling_rate"] = 4
        
        json["TEMP"] = Array(skinTempMap.values)
        
        json["ECG"] = Array(heartRateMap.values)

        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("🔥 AHS Error!")
                print(error.localizedDescription)
                return
            }

            guard let data = data else {
                print("🔥 AHS Error!")
                print("No data received.")
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("🔥 Received JSON string: \(jsonString)")
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("🔥 AHS - All right!")
                    if let prediction = PredictionServices.predictHeatStrain(inputFeatures: json) {
                        if self.modelData != nil {
                            // Update the local prediction
                            DispatchQueue.main.async {
                                self.modelData!.heatStrain = prediction
                            }
                            
                            // Upload this prediction!
                            let deviceId = UIDevice.current.identifierForVendor?.uuidString
                            let docName: String = Utilities.timestampToDateString(Date().timeIntervalSince1970);
                            
                            Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
                                .collection("heat_strain_levels").document(docName).setData([
                                    "device_uuid": deviceId ?? "Not Avaliable",
                                    "heat_strain_level": prediction,
                                    "timestamp": Date().timeIntervalSince1970
                                ]) { err in
                                    if let err = err {
                                        print("Error adding document: \(err)")
                                    } else {
                                        print("Document \(docName) successfully written!")
                                        print("⬆️ [Heat Straun] Uploaded 1 Double.")
                                    }
                                }
                        }
                    }
                    
                } else {
                    print("🔥 AHS - Invalid JSON format.")
                }
            } catch {
                print("🔥 AHS Error!")
                print(error.localizedDescription)
            }
        }
        task.resume()
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
        
        if (HRR - userInfoLoader.hr_reserve_cp > 0) {
        self.awc_exp = max(self.awc_exp + Double(userInfoLoader.k_value) * (Double(HRR) - Double(userInfoLoader.hr_reserve_cp)), 0)
        }

        else {
        self.awc_exp = max(self.awc_exp + 2.4 * Double(userInfoLoader.k_value) * (Double(HRR) - Double(userInfoLoader.hr_reserve_cp)), 0)
        }
        
        let fatigue = Int(Double(self.awc_exp) / Double(userInfoLoader.total_awc) * 100)
        print("fatigue = \(fatigue)")
        
        // update UI
        print("fatigue updated")
        delegate?.updateHeartRate(self, heartRate: avgHR)
        delegate?.updateFatigueLevel(self, fatigueLevel: fatigue)
        
        // upload to server
        uploadFatigueLevel(fatigueLevel: fatigue, timestamp: Date().timeIntervalSince1970)
        FirebaseManager.uploadHeartRate(hrMap: self.heartRateMap)
        FirebaseManager.uploadBVPdata(BVPmap: self.BVPmap)
        FirebaseManager.uploadGSRdata(GSRmap: self.GSRmap)
        FirebaseManager.uploadSkinTemps(skinTempMap: self.skinTempMap)
        
        // reset
        self.heartRates = []
        self.heartRateMap = [:]
        self.BVPmap = [:]
        self.GSRmap = [:]
        self.skinTempMap = [:]
        
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
        if modelData != nil && !(modelData!).shouldDisableMetricDisplays {
            NodeServer.sendFatigueWarning(firstName: firstName, fatigueLevel: fatigueLevel, groupId: groupId)
        }
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

    /// Called when the app receives IBI data from the wristband.
    func didReceiveIBI(_ ibi: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        // calculate HR
        
        // unrealistic heart rate?
        if ibi == 0 {
            print("❤️ An IBI of \(ibi) was identified.")
            return
        }
        let heartRate = Int(60.0 / ibi)
        print("❤️‍🔥 OK IBI identified! \(ibi) -> HR: \(Int(60.0 / ibi)) [MHR: \(max_heart_rate)]")
        if (heartRate > max_heart_rate) {
            return
        }
        
        let avgHR = getAverageHeartRate()
        print(" ❤️ Avg. HR = \(avgHR)")
        if (avgHR == 0 || (avgHR != 0 && abs(heartRate - avgHR) < 30)) {
            print("❤️ Heart rate identified! \(heartRate)")
            heartRates.append(heartRate)
            heartRateMap[Utilities.timestampToDateString(timestamp)] = heartRate
        }
        
        // check time interval
        print("⏰ checking time since last update - timestamp: \(timestamp), LUT: \(self.lastUpdateTime), subtraction: \(timestamp - self.lastUpdateTime)")
        if (timestamp - self.lastUpdateTime > 60) {
            delegate?.updateHeartRate(self, heartRate: heartRate) // UI
            assessHeatStrain()
            assessFatigue()
        }
        print("\(device.serialNumber!) \(timestamp) IBI { \(ibi) }")
    }
    
    /// Called when the app receives GSR data from the wristband.
    func didReceiveGSR(_ gsr: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        print("🛜 Received GSR data of \(gsr) from the wristband!")
        GSRmap[Utilities.timestampToDateString(timestamp)] = gsr
    }
    
    /// Called when the app receives BVP data from the wristband.
    func didReceiveBVP(_ bvp: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        print("🛜 Received BVP data of \(bvp) from the wristband! - #\(BVPmap.count + 1)")
        BVPmap[Utilities.timestampToDateString(timestamp)] = bvp
    }
    
    /// Called when the app receives temperature data from the wristband.
    func didReceiveTemperature(_ temp: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        print("🌡️ Received temp data of \(temp) from the wristband!")
        skinTempMap[Utilities.timestampToDateString(timestamp)] = temp
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
            
            // Schedule the EMA survey notifications!
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
                if granted {
                    
                    for i in 1...3 {
                        let content = UNMutableNotificationContent()
                        content.title = "Time to take a quick survey!"
                        content.body = "Please tap here to complete the two-question survey."
                        content.sound = UNNotificationSound.default
                        content.categoryIdentifier = "EMA_SURVEY_\(UUID().uuidString)"
                        
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(i * 7200), repeats: false)
                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                        
                        notificationCenter.add(request) { error in
                            if let error = error {
                                print("Error scheduling notification: \(error.localizedDescription)")
                            }
                        }
                    }
                } else {
                    if let error = error {
                        print("Error requesting notifications permission: \(error.localizedDescription)")
                    }
                }
            }
            
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

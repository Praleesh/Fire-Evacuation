//
//  menu.swift
//  FireEvacuation
//
//  Created by Amritha on 11/04/23.
//

import UIKit

class HomeVc: UIViewController, UIScrollViewDelegate{
    
    @IBOutlet weak var classNameLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var goodmorninglabel: UILabel!
    var timer: Timer?
    @IBOutlet weak var assemblyPointLabel: UILabel!
    @IBOutlet weak var studentImageView1: UIImageView!
    @IBOutlet weak var studentImageView2: UIImageView!
    @IBOutlet weak var studentImageView3: UIImageView!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var studentDetailsLabel: UILabel!
    
    var idTaken: String?
    var subjectTaken: String?
    
    var totalStudents: Int = 0
    
    // pan view
    @IBOutlet weak var movableView: UIView!
    var panGesture: UIPanGestureRecognizer!
    @IBOutlet weak var panview: UIView!
    var initialViewPosition: CGPoint!
    @IBOutlet weak var evacuateNowView: UIView!
    @IBOutlet weak var assemblePointView: UIView!
    
    var SESSIONIN           = API_Manager().Header + API_Manager().sessionin
    var SESSIONOUT          = API_Manager().Header + API_Manager().sessionout
    var ASSEMBLYPOINTS      = API_Manager().Header + API_Manager().assemblypoints
    var DEVICEDATA          = API_Manager().Header + API_Manager().devicedata
    var GETCLASSSTUDENTS    = API_Manager().Header + API_Manager().getclassstudents
    var EVACUATIONSTATUS    = API_Manager().Header + API_Manager().evacuationstatus
    var LOGOUT              = API_Manager().Header + API_Manager().logout
    
    // MARK: - popup
    @IBOutlet weak var popupview: UIView!
    @IBOutlet weak var popupbgview: UIView!
    @IBOutlet weak var popupsessionview: UIView!
    @IBOutlet weak var popupsubjectview: UIView!
    @IBOutlet weak var popupcheckinbutton: UIButton!
    @IBOutlet weak var popupclosebutton: UIButton!
    @IBOutlet weak var popupsessionbutton: UIButton!
    @IBOutlet weak var popupsubjectbutton: UIButton!
    
    // MARK: - popup-options
    @IBOutlet weak var popSessionOptionView: UIView!
    @IBOutlet weak var popSubjectOptionView: UIView!
    var selectedSubjectIndex = -1
    var selectedSesssionIndex = -1
    @IBOutlet weak var sessionLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    
    var yearGroupModelArray = [YearGroupModel]()
    var subjectModelArray = [SubjectsModel]()
    var assemblyModelArray = [AssemblyModel]()
    var classStudentsModelArray = [ClassStudentsModel]()
    var evacuationStatusModelArray = [EvacuationStatusModel]()
    var assemblyPointsModelArray = [AssemblyModel]()
    
    // MARK: - tableviews
    @IBOutlet weak var popupsessiontableview: UITableView!
    @IBOutlet weak var popupsubjtableview: UITableView!
    
    // MARK: - yeargroup
    var yearGroupSelectUrl = API_Manager().Header + API_Manager().yeargroups
    var subjectSelectUrl = API_Manager().Header + API_Manager().getclasssubjects
    
    
    @IBOutlet weak var staffNameLabel: UILabel!
    @IBOutlet weak var subjectInLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.isHidden = true
        
        self.currentDate()
        self.makeNetworkCallForDeviceData()
        
        popupview.alpha = 1
        popupbgview.alpha = 0.6
        popSessionOptionView.alpha = 0
        popSubjectOptionView.alpha = 0
        
        self.panview.layer.cornerRadius = 5
        self.panview.layer.masksToBounds = true
        self.movableView.layer.cornerRadius = 5
        self.movableView.layer.masksToBounds = true
        self.evacuateNowView.layer.cornerRadius = 5
        self.evacuateNowView.layer.masksToBounds = true
        self.assemblePointView.layer.cornerRadius = 5
        self.assemblePointView.layer.masksToBounds = true
        
        // MARK:- Start the timer when the view loads
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateLabel), userInfo: nil, repeats: true)
        
        // MARK:- pan gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        movableView.addGestureRecognizer(panGesture)
        initialViewPosition = movableView.center
        
        // MARK:- popup
        popupview.layer.borderWidth = 1
        popupview.layer.cornerRadius = 10
        popupsessionview.layer.cornerRadius = 5
        popupsubjectview.layer.cornerRadius = 5
        popupcheckinbutton.layer.cornerRadius = 5
        popSubjectOptionView.layer.cornerRadius = 5
        popSubjectOptionView.layer.masksToBounds = true
        popSessionOptionView.layer.cornerRadius = 5
        popSessionOptionView.layer.masksToBounds = true
        
        
        self.popupsessiontableview.register(UINib(nibName: "PopupTableViewCell", bundle: nil), forCellReuseIdentifier: "PopupTableViewCell")
        self.popupsubjtableview.register(UINib(nibName: "PopupTableViewCell", bundle: nil), forCellReuseIdentifier: "PopupTableViewCell")
        
        popupsessiontableview.separatorStyle = .none
        popupsubjtableview.separatorStyle = .none
        
        //Tab bar icon remove tint and appear as it is
        tabBarItem.image = UIImage(named: "Home")?.withRenderingMode(.alwaysOriginal)

        // Set the selected image for the tab bar item
        tabBarItem.selectedImage = UIImage(named: "HomeSelected")?.withRenderingMode(.alwaysOriginal)
        
        // data retrieved
        staffNameLabel.text = DefaultWrapper.shared.staffName
        

    }
    
    
    @IBAction func didStudentDetailsButtonTapped() {
        self.navigateToStudentDetails()
    }
    
    @IBAction func popupclosebuttontapped(sender: UIButton){
        self.makeNetworkCallForCheckOut()
        DefaultWrapper.shared.signedIn = 0
        
    }
    
    @IBAction func checkInButtonTapped(_sender: UIButton) {
    
        if sessionLabel.text != "" && subjectLabel.text != "" {
            popupview.alpha = 0
            popupbgview.alpha = 0
            self.makeNetworkCallForSessionIn()
            self.makeNetworkCallForGetClassStudents()
            self.makeNetworkCallForAssemblyPoints()
            self.assemblyPointLabel.text = DefaultWrapper.shared.assemblypoint
            self.classNameLabel.text = DefaultWrapper.shared.classname
        } else {
            Common.alert(alertMessageParameter: "Select Session and Subject")
        }
    }
    
    func navigateToStudentDetails() {
        let stryBrd = UIStoryboard(name: "Main", bundle: nil)
        let newVc = stryBrd.instantiateViewController(withIdentifier: "StudentDetailsViewController") as! StudentDetailsViewController
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
        present(newVc, animated: true, completion: nil)
    }
    
    @objc func updateLabel()
    {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 6 && hour < 12 {
            goodmorninglabel.text = "Good morning!"
        } else if hour >= 12 && hour < 18 {
            goodmorninglabel.text = "Good afternoon!"
        } else {
            goodmorninglabel.text = "Good evening!"
        }
    }
    deinit {
        // Stop the timer when the view is deallocated
        timer?.invalidate()
        timer = nil
    }
    
    func currentDate(){
        // Create a DateFormatter object
        // Create a DateFormatter object with the desired date format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        
        // Get the current date as a string formatted according to the date formatter
        let dateString = dateFormatter.string(from: Date())
        
        // Set the text of your label to the formatted date string
        self.currentDateLabel.text = dateString
        
        DefaultWrapper.shared.date = dateString
        
        
        
    }
    
    // MARK: - pan-gesture
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: panview)
        
        let newXPosition = max(min(movableView.center.x + translation.x, panview.bounds.width - movableView.bounds.width / 2), movableView.bounds.width / 2)
        let newYPosition = movableView.center.y
        
        movableView.center = CGPoint(x: newXPosition, y: newYPosition)
        
        gesture.setTranslation(.zero, in: panview)
        
        if newXPosition == movableView.bounds.width / 2 && gesture.state == .ended {
            DefaultWrapper.shared.signedIn = 3
            self.makeNetworkCallForSessionOut()
            self.navigateToTabBar()
            // The view is at the left end of the pan view
        }
        
        if gesture.state == .ended {
            if newXPosition == panview.bounds.width - movableView.bounds.width / 2 {
                // The view is at the right end of the pan view
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.movableView.center = self.initialViewPosition
                }
            }
        }
    }
    
    func navigateToTabBar() {
        // Your navigation code here
        print("Navigate to next view")
        let storyBrd = UIStoryboard(name: "Main", bundle: nil)
        let signVc = storyBrd.instantiateViewController(withIdentifier: "TabBar") as! TabBar
        self.navigationController?.pushViewController(signVc, animated: true)
    }
    
    func navigateToAttendanceViewController() {
        let storyBrd = UIStoryboard(name: "Main", bundle: nil)
        DispatchQueue.main.async {
            let AttendanceVc = storyBrd.instantiateViewController(withIdentifier: "Attendance") as! Attendance
            self.navigationController?.pushViewController(AttendanceVc, animated: true)
        }
    }
    
    //    // MARK: - button sound
    //    @objc func playSystemSound() {
    //        let soundID: SystemSoundID = 1103 // You can replace this with any system sound ID
    //        AudioServicesPlaySystemSound(soundID)
    //    }
    
    @IBAction func sessionbuttontapped(_sender: UIButton) {
        popSessionOptionView.alpha = 1
        self.yearGroupSelect()
        popupsessiontableview.reloadData()
        subjectLabel.text = ""
        popupsubjtableview.reloadData()
    }
    
    @IBAction func subjectbuttontapped(_sender: UIButton) {
        if sessionLabel.text != "" {
        self.makeNetworkCallForSubject()
        } else {
            Common.alertLogin(alertMessageParameter: "Select Session")
        }
    }
    
    @IBAction func didBgButtonTapped() {
        self.popSessionOptionView.alpha = 0
        self.popSubjectOptionView.alpha = 0
    }
    
    @IBAction func evacuateButtonTapped(_ sender: Any) {
        
        print("evacuation button tapped")
        
        print("evacuation id while evacuate button tapped: \(DefaultWrapper.shared.evacuationid)")
        
           makeNetworkCallForEvacuationStatus { [weak self] in
               guard self == self else { return }
               if DefaultWrapper.shared.evacuatedStatus == 0 {
                   print("no evacuation in progress")
                   Common.alertLogin(alertMessageParameter: "No Evacuation In Progress")
               } else {
                   self!.navigateToAttendanceViewController()
               }
           }
    }
}
// MARK: - popuptableview

extension HomeVc: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == popupsessiontableview{
            
            return yearGroupModelArray.count
        } else {
            return subjectModelArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PopupTableViewCell", for: indexPath) as! PopupTableViewCell
        if tableView == popupsessiontableview{
            cell.popTableLabel.text = yearGroupModelArray[indexPath.row].year_group
            cell.poptableimageview.image = UIImage(named: "radiooff")
            if indexPath.row == selectedSesssionIndex {
                cell.poptableimageview.image = UIImage(named: "radioon")
            }
        }else {
            cell.popTableLabel.text = subjectModelArray[indexPath.row].name
            cell.popTableLabel.font = UIFont(name: "VerdanaPro-Light", size: 14) ?? UIFont.systemFont(ofSize: 14)
            cell.poptableimageview.image = UIImage(named: "radiooff")
            if indexPath.row == selectedSubjectIndex {
                cell.poptableimageview.image = UIImage(named: "radioon")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? PopupTableViewCell
        if tableView == popupsessiontableview{
            self.selectedSesssionIndex = indexPath.row
            popSessionOptionView.alpha = 0
            DefaultWrapper.shared.classid = "\(yearGroupModelArray[indexPath.row].id ?? 0)"
            print("Default : \(DefaultWrapper.shared.classid)")
            self.sessionLabel.text = yearGroupModelArray[indexPath.row].year_group ?? ""
            DefaultWrapper.shared.classname = yearGroupModelArray[indexPath.row].year_group ?? ""
            print("DefaultWrapper.shared.classname: \(DefaultWrapper.shared.classname)")
        }
        else {
            self.selectedSubjectIndex  = indexPath.row
            popSubjectOptionView.alpha = 0
            //            subjectTaken = "\(subjectModelArray[indexPath.row].)"
            self.subjectLabel.text = subjectModelArray[indexPath.row].name ?? ""
            self.subjectInLabel.text = subjectModelArray[indexPath.row].name ?? ""
            DefaultWrapper.shared.subject = subjectModelArray[indexPath.row].name ?? ""
            print("DefaultWrapper.shared.subject: \(DefaultWrapper.shared.subject)")
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0) //for header to be idle
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 30))
        headerView.backgroundColor = #colorLiteral(red: 0.9254901961, green: 0.9254901961, blue: 0.9254901961, alpha: 1)
        let label = UILabel()
        label.frame = CGRect.init(x: 10, y: 5, width: headerView.frame.width-20, height: headerView.frame.height-10)
        label.text = ""
        if tableView == popupsessiontableview{
            label.text = "Select Session"
        }else {
            label.text = "Select Subject"
        }
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .black
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    // MARK: - YEAR GROUP
    
    func yearGroupSelect() {
        
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        let url = URL(string: yearGroupSelectUrl)
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let token = DefaultWrapper.shared.tokengenerated
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        session.dataTask(with: urlRequest) { (data, response, err) in
            if let err = err {
                print(err.localizedDescription)
            }
            if let jsonData = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
                    //                    print("JSON \(json)")
                    if let convDict = json as? [String: Any] {
                        //                        print("Dictionary Of data: \(convDict)")
                        if let dataObtained = convDict["data"]as? [[String: Any]] {
                            //                                                       print("Data Obtained: \(dataObtained)")
                            
                            self.yearGroupModelArray = []
                            
                            for i in dataObtained {
                                self.yearGroupModelArray.append(YearGroupModel(fromData: i))
                            }
                            
                            DispatchQueue.main.async {
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.isHidden = true
                                
                                self.popupsessiontableview.reloadData()
                            }
                            //                            print("My Model \(self.myModel.count)")
                        }
                    }
                }catch{
                    print("Error")
                }
            }
        }.resume()
    }
    
    //MARK: - SUBJECT
    
    func makeNetworkCallForSubject() {
        
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        print("Default Printed: \(DefaultWrapper.shared.classid)")
        
        guard let Url = URL(string: subjectSelectUrl ) else { return }
        let parameters: [String:Any] = [
            "class_id": DefaultWrapper.shared.classid
        ]
        var components = URLComponents(url: Url, resolvingAgainstBaseURL: false)!
        components.queryItems = parameters.map { key, value in
            URLQueryItem(name: key, value: String(describing: value))
        }
        var urlRequest = URLRequest(url: components.url!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(DefaultWrapper.shared.tokengenerated)", forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        session.dataTask(with: urlRequest) { (data, response, err) in
            
            if let err = err {
                print(err.localizedDescription)
            }
            //            print("Id Selected: \(DefaultWrapper.shared.classid)")
            if let jsondata = data{
                do {
                    let json = try JSONSerialization.jsonObject(with: jsondata, options:[])
                    //                    print("JSON ID FOR SUBJECT \(json)")
                    
                    if let convDict = json as? [String: Any] {
                        //                        print("array of Dictionary: \(convDict)")
                        if let successKey = convDict["success"] as? Bool {
                            
                            if successKey == true {
                                
                                if let respData = convDict["data"]as? [[String: Any]] {
                                    //                            print("Response Data: \(respData)")
                                    if !respData.isEmpty {
                                        
                        
                                    self.subjectModelArray = []
                                    
                                    for i in respData {
                                        self.subjectModelArray.append(SubjectsModel(fromData: i))
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.activityIndicator.stopAnimating()
                                        self.activityIndicator.isHidden = true
                                        self.popSubjectOptionView.alpha = 1
                                        self.popupsubjtableview.reloadData()
                                    }
                                    }else{
                                        DispatchQueue.main.async {
                                            self.activityIndicator.stopAnimating()
                                            self.activityIndicator.isHidden = true
                                            Common.alert(alertMessageParameter: "No Subject Available")
                                        }
                                    }
                                    
                                    
                                }
                            }else {
                                DispatchQueue.main.async {
                                    self.activityIndicator.stopAnimating()
                                    self.activityIndicator.isHidden = true
                                }
                            }
                        }
                    }
                } catch {
                    print("err")
                }
            }
        }.resume()
    }
    
    //MARK: - SESSION IN
    
    func makeNetworkCallForSessionIn() {
        
        guard let Url = URL(string: SESSIONIN) else { return }
        
        var req = URLRequest(url: Url)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(DefaultWrapper.shared.tokengenerated)", forHTTPHeaderField: "Authorization")
        req.httpMethod = "POST"
        
        let parameters: [String: Any] = [
            "latitude": "11",
            "longitude": "11"
        ]
        do {
            let body = try JSONSerialization.data(withJSONObject: parameters, options: [])
            req.httpBody = body
        }catch {
            print("Error")
        }
        let session = URLSession.shared
        session.dataTask(with: req) { data, resp, err in
            //            print(data!)
            
            if let Error = err {
                print(Error.localizedDescription)
            }
            
            if let jsonData = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
                    //                    print(json)
                    
                    if let convDict = json as? [String: Any] {
                        print("Checkin Dictionary: \(convDict)")
                    }
                }catch{
                    print("Error")
                }
            }
        }.resume()
    }
    
    
    //MARK: - SESSION OUT
    
    func makeNetworkCallForSessionOut() {
        
        guard let Url = URL(string: SESSIONOUT) else { return }
        
        var req = URLRequest(url: Url)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(DefaultWrapper.shared.tokengenerated)", forHTTPHeaderField: "Authorization")
        req.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: req) { data, resp, err in
            // print(data!)
            
            if let Error = err {
                print(Error.localizedDescription)
            }
            
            if let jsonData = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
                     print("session out json: \(json)")
                }catch{
                    print("Error")
                }
            }
        }.resume()
    }
    
    //MARK: -  ASSEMBLY POINTS
    
    func makeNetworkCallForAssemblyPoints() {
        
        guard let Url = URL(string: ASSEMBLYPOINTS) else { return }
        var req = URLRequest(url: Url)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(DefaultWrapper.shared.tokengenerated)", forHTTPHeaderField: "Authorization")
        req.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: req) { datainbyte, responseinbyte, errorinbyte in
            //            print(data!)
            if let Error = errorinbyte {
                print(Error.localizedDescription)
            }
            if let dataConv = datainbyte {
                do {
                    // Parse the JSON response and create an array of AssemblyPoint objects
                    if let json = try JSONSerialization.jsonObject(with: dataConv, options: []) as? [String: Any],
                       
                        let data = json["data"] as? [[String: Any]] {
                        
                        for assemblyPointData in data {
                            if let id = assemblyPointData["id"] as? Int,
                               let assemblyPoint = assemblyPointData["assembly_point"] as? String,
                               let classes = assemblyPointData["classes"] as? [String] {
                                let assemblyPointObject = AssemblyModel(id: id, assemblyPoint: assemblyPoint, classes: classes)
                                self.assemblyPointsModelArray.append(assemblyPointObject)
                            }
                        }
                        
                        // Access the array of AssemblyPoint objects
                        for i in self.assemblyPointsModelArray.indices {
                            //                          print("assesmbly point: \(assemblyPoints[i].assemblyPoint)")
                            for j in self.assemblyPointsModelArray[i].classes.indices {
                                print("classes: \(self.assemblyPointsModelArray[i].classes[j])")
                                let temp = self.assemblyPointsModelArray[i].classes[j].replacingOccurrences(of: " ", with: "")
                                if DefaultWrapper.shared.classname == temp {
                                    print("temp: \(temp)")
                                    DefaultWrapper.shared.assemblypoint = self.assemblyPointsModelArray[i].assemblyPoint
                                    print("DefaultWrapper.shared.assemblypoint: \(DefaultWrapper.shared.assemblypoint)")
                                }
                            }
                        }
                    } else {
                        print("Error parsing JSON")
                    }
                }catch{
                    print("Error")
                }
            }
            
        }.resume()
        
    }
    
    //MARK: - DEVICE DATA
    
    func makeNetworkCallForDeviceData() {
        
        guard let Url = URL(string: DEVICEDATA) else { return }
        // Get the device type
        let deviceType = UIDevice.current.userInterfaceIdiom.rawValue
        // Get the device ID
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
        // Get the device name
        let deviceName = UIDevice.current.name
        // Get the app version
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        // Get the FCM ID (assuming you have Firebase installed and configured in your app)
        //  let fcmID = Messaging.messaging().fcmToken ?? "Unknown"
        
        let parameters: [String: Any] = [
            "device_type": deviceType,
            "device_id": deviceID,
            "device_name": deviceName,
            "fcm_id": "1",
            "app_version": appVersion
        ]
        
        var components = URLComponents(url: Url, resolvingAgainstBaseURL: false)!
        components.queryItems = parameters.map { key, value in
            URLQueryItem(name: key, value: String(describing: value))
        }
        
        var req = URLRequest(url: components.url!)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(DefaultWrapper.shared.tokengenerated)", forHTTPHeaderField: "Authorization")
        req.httpMethod = "POST"
        let session = URLSession.shared
        session.dataTask(with: req) { data, resp, err in
            //            print(data!)
            
            if let Error = err {
                print(Error.localizedDescription)
            }
            
            if let jsonData = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
                    //                    print(json)
                    
                    if let convDict = json as? [String: Any] {
                            print("Device Data Dictionary: \(convDict)")
                    }
                }catch{
                    print("Error")
                }
            }
        }.resume()
    }
    
    //MARK: - GET CLASS STUDENTS
    
    func makeNetworkCallForGetClassStudents() {
        
        print("newclassidnewclassid: \(DefaultWrapper.shared.classid)")
        
        guard let Url = URL(string: GETCLASSSTUDENTS) else { return }
        let parameters: [String:Any] = [
            "class_id": DefaultWrapper.shared.classid
        ]
        var components = URLComponents(url: Url, resolvingAgainstBaseURL: false)!
        components.queryItems = parameters.map { key, value in
            URLQueryItem(name: key, value: String(describing: value))
        }
        var req = URLRequest(url: components.url!)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(DefaultWrapper.shared.tokengenerated)", forHTTPHeaderField: "Authorization")
        req.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: req) { datainbyte, responseinbyte, errorinbyte in
            //           print("datainbyte: \(datainbyte!)")
            if let Error = errorinbyte {
                print(Error.localizedDescription)
            }
            if let dataConv = datainbyte {
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: dataConv)
                    //                   print("jsonDatas: \(jsonData)")
                    
                    if let convDict = jsonData as? [String: Any] {
                        //                       print("Dictionary: \(convDict)")
                        
                        if let respdata = convDict["data"] as? [[String:Any]] {
                            //                            print("respdata: \(respdata)")
                            
                            for i in respdata{
                                self.classStudentsModelArray.append(ClassStudentsModel(fromdata: i))
                            }
                            //                            print(self.classStudents[0].full_name!)
                            let imageUrl3 = URL(string: self.classStudentsModelArray[2].profile_photo_path!)
                            let imageUrl2 = URL(string: self.classStudentsModelArray[1].profile_photo_path!)
                            let imageUrl1 = URL(string: self.classStudentsModelArray[0].profile_photo_path!)
                            
                            let task1 = URLSession.shared.dataTask(with: imageUrl1!) { (data, response, error) in
                                if let data = data {
                                    DispatchQueue.main.async {
                                        self.studentImageView1.image = UIImage(data: data)
                                        self.totalStudents = self.classStudentsModelArray.count
                                        self.totalLabel.text = "\(self.totalStudents)"
                                        self.studentDetailsLabel.text = "+\(self.totalStudents - 3) "
                                    }
                                }
                            }
                            task1.resume()
                            
                            let task2 = URLSession.shared.dataTask(with: imageUrl2!) { (data, response, error) in
                                if let data = data {
                                    DispatchQueue.main.async {
                                        self.studentImageView2.image = UIImage(data: data)
                                    }
                                }
                            }
                            task2.resume()
                            
                            let task3 = URLSession.shared.dataTask(with: imageUrl3!) { (data, response, error) in
                                if let data = data {
                                    DispatchQueue.main.async {
                                        self.studentImageView3.image = UIImage(data: data)
                                    }
                                }
                            }
                            task3.resume()
                        }
                    }
                }catch{
                    print("Error")
                }
            }
            
        }.resume()
        
    }
    
    //MARK: - EVACUATION STATUS
    
    func makeNetworkCallForEvacuationStatus(completion: @escaping () -> Void) {
        
        DefaultWrapper.shared.evacuatedStatus = 0
        
        guard let Url = URL(string: EVACUATIONSTATUS) else { return }
        var req = URLRequest(url: Url)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(DefaultWrapper.shared.tokengenerated)", forHTTPHeaderField: "Authorization")
        req.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: req) { data, resp, err in
            //            print(data!)
            
            if let Error = err {
                print(Error.localizedDescription)
            }
            if let jsonData = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
                    //                        print("json: \(json)")
                    
                    
                    if let jsonDict = json as? [String: Any],
                        //                            print("jsonDict: \(jsonDict)")
                        
                        let jsonConv = jsonDict["data"] as? [[String: Any]] {
                                print("Evacuation status jsonConv: \(jsonConv)")
                          
                        self.evacuationStatusModelArray = []
                            
                            for i in jsonConv {
                                self.evacuationStatusModelArray.append(EvacuationStatusModel(fromdata: i))
                            }
                        for i in self.evacuationStatusModelArray {
                            if let status = i.status {
                                
                                if status == 1 {
                                    DefaultWrapper.shared.evacuatedStatus = 1
                                    DefaultWrapper.shared.evacuationid = i.evacuate_id ?? ""
                            }
                        }
                    }
                            
                            DispatchQueue.main.async {
                                completion()
                        }
                        
                    }
                }catch {
                    print("error")
                }
            }
        }.resume()
    }
    
    // MARK: - CHECKOUT
    
    func makeNetworkCallForCheckOut() {
        
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        guard let url = URL(string: LOGOUT) else { return }
        var urlrequest = URLRequest(url: url)
        urlrequest.httpMethod = "POST"
        let token = DefaultWrapper.shared.tokengenerated
        urlrequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlrequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        session.dataTask(with: urlrequest) { (datainbyte, responseinbyte, errorinbyte) in
            if let error = errorinbyte
            {
                print("error\(error.localizedDescription)")
            }
            if let dataconv = datainbyte {
                do
                {
                    //byte to jsonobject
                    let jsonData = try JSONSerialization.jsonObject(with: dataconv, options: [])
                    print(jsonData)
                    // jsonobject to arrayofdictionary
                    if let json = jsonData as? [String:Any] {
                        print(json)
                        
                        if let statusKey = json["status"] as? Int{
                            print("check out Key: \(statusKey)")
                            DispatchQueue.main.async {
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.isHidden = true
                                if statusKey == 200
                                {
                                    self.navigatetoSignIn()
                                }else {
                                    if statusKey == 417
                                    {
                                        print("error")
                                    }
                                }
                            }
                            
                        }
                    }
                    
                }
                catch
                {
                    print("Error")
                }
            }
        }.resume()
    }
    
    func navigatetoSignIn() {
        let stryBrd = UIStoryboard(name: "Main", bundle: nil)
        let newVc = stryBrd.instantiateViewController(withIdentifier: "Sign_In") as! Sign_In
        navigationController?.pushViewController(newVc, animated: true)
    }
    
    
}


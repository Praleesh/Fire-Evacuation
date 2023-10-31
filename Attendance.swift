
//
//  attendance.swift
//  FireEvacuation
//
//  Created by Amritha on 19/04/23.
//

import UIKit
import Firebase
import FirebaseDatabase

class Attendance: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var classTableView: UITableView!
    @IBOutlet weak var schoolTableView: UITableView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    
    @IBOutlet weak var searchViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchNoActionView: UIView!
    let pangesture = UIPanGestureRecognizer()
    
    var studentName: String?
    
    var evacuated: String?
    
//    let databaseRef = Database.database().reference()
    
    @IBOutlet weak var viewSummaryButton: UIButton!
    
    var successfulCount = 0
    
    let evacuationStudentsRef = Database.database().reference().child("evacuation_students").child("\(DefaultWrapper.shared.evacuationid)")
    
    var schoolDataModelArray = [SchoolDataModel]()
    
    var currentClassModelArray = [ClassCurrentModel]()
    
    var currentTable: UITableView?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // search bar
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchTableInView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!

//    var data: [CellData] = [] // Your original data array
    
    var filteredData: [SchoolDataModel] = [] // Filtered data array
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the table view
        searchTableView.dataSource = self

        // Set up the search bar
        searchBar.delegate = self
        
        self.searchNoActionView.isHidden = true
        self.searchBarView.isHidden = true
        self.searchTableInView.isHidden = true
        
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        segmentedControl.addGestureRecognizer(pangesture)
        pangesture.addTarget(self, action: #selector(handlePanGesture))
        
        // MARK: - register tableviewcell
        
        self.searchTableView.register(UINib(nibName: "AttendanceTableViewCell", bundle: nil), forCellReuseIdentifier: "AttendanceTableViewCell")
        
        self.classTableView.register(UINib(nibName: "AttendanceTableViewCell", bundle: nil), forCellReuseIdentifier: "AttendanceTableViewCell")
        
        self.schoolTableView.register(UINib(nibName: "AttendanceTableViewCell", bundle: nil), forCellReuseIdentifier: "AttendanceTableViewCell")
        
        dateLabel.text = DefaultWrapper.shared.date
        
        classLabel.text = DefaultWrapper.shared.classname
        
        subjectLabel.text = DefaultWrapper.shared.subject
        
        print(evacuationStudentsRef)
        self.classTableView.alpha = 1
        self.schoolTableView.alpha = 0
        self.currentTable = classTableView
        
        evacuationStudentsRef.observe(.value, with: { [self] (snapshot) in
            
            print(snapshot)
            
            let studentsCount = snapshot.childrenCount
             
            print("Child node count: \(studentsCount)")
            
            self.schoolDataModelArray = []
            
            var successfulCount = 0    // for getting students evacuated value
            
            for case let child as DataSnapshot in snapshot.children {
                        let student_name = child.childSnapshot(forPath: "student_name").value as? String ?? ""
                        let student_id = child.childSnapshot(forPath: "student_id").value as? Int ?? 0
                        let student_class_section = child.childSnapshot(forPath: "student_class_section").value as? String ?? ""
                        let evacuated = child.childSnapshot(forPath: "evacuated").value as? Int ?? 0
                let temp = SchoolDataModel(student_name: student_name, student_id: student_id, student_class_section: student_class_section, evacuated: evacuated)
                        self.schoolDataModelArray.append(temp)
                    }
            
            DefaultWrapper.shared.totalstudents = schoolDataModelArray.count
            print("total students in school: \(DefaultWrapper.shared.totalstudents)")
            successfulCount = 0
            for i in schoolDataModelArray.indices {
                if schoolDataModelArray[i].evacuated == 1 {
                    successfulCount += 1
                }
            }
            DefaultWrapper.shared.studentsEvacuated = successfulCount
            print("students evacuated count: \(DefaultWrapper.shared.studentsEvacuated)")
            
            self.currentClassModelArray = []
            
            for student in self.schoolDataModelArray {
                if DefaultWrapper.shared.classname.contains(student.student_class_section ?? "") {
                    // append to current class array
                    let student_name = student.student_name ?? ""
                    let student_id = student.student_id ?? 0
                    let student_class_section = student.student_class_section ?? ""
                    let evacuated = student.evacuated ?? 0
                    let temp = ClassCurrentModel(student_name: student_name, student_id: student_id, student_class_section: student_class_section, evacuated: evacuated)
                    self.currentClassModelArray.append(temp)
                }
            }
            self.schoolTableView.reloadData()
            self.classTableView.reloadData()
            
        }) { (error) in
            print("Error: \(error.localizedDescription)")
        }
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
        
        
    }
    
    @IBAction func didSearchButtonClicked() {
        self.searchBarView.isHidden = false
        self.searchTableInView.isHidden = false
        self.searchNoActionView.isHidden = false
        schoolTableView.isUserInteractionEnabled = false
        tapgesture()
    }
    
    @IBAction func didSearchCloseButtonTapped() {
        self.searchTableInView.isHidden = true
        self.searchBarView.isHidden = true
        self.searchNoActionView.isHidden = true
        searchBar.resignFirstResponder()
        schoolTableView.isUserInteractionEnabled = true
    }
    
    func tapgesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        // Resign first responder status of the text field
        self.searchTableInView.isHidden = true
        self.searchBarView.isHidden = true
        self.searchNoActionView.isHidden = true
        searchBar.resignFirstResponder()
        schoolTableView.isUserInteractionEnabled = true
        if (segmentedControl.selectedSegmentIndex != 0) {
            currentTable = schoolTableView
        }else {
            currentTable = classTableView
        }
    }
    
                           
    @IBAction func didViewSummaryButtonTapped() {
        let stryBrd = UIStoryboard(name: "Main", bundle: nil)
        let newVc = stryBrd.instantiateViewController(withIdentifier: "SummaryViewController") as! SummaryViewController
        self.navigationController?.pushViewController(newVc, animated: true)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
            switch sender.selectedSegmentIndex {
            case 0:
                self.currentTable = classTableView
                self.classTableView.alpha = 1
                self.schoolTableView.alpha = 0
                classTableView.reloadData()
            case 1:
                self.currentTable = schoolTableView
                self.classTableView.alpha = 0
                self.schoolTableView.alpha = 1
                schoolTableView.reloadData()
            default:
                break
            }
        }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == classTableView {
            return currentClassModelArray.count
        } else if tableView == schoolTableView {
            return schoolDataModelArray.count
        }
            else if tableView == searchTableView {
                return filteredData.count
            }
        else {
            // Default to returning zero if the table view is not recognized
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceTableViewCell", for: indexPath) as! AttendanceTableViewCell
        
        cell.attendanceTableViewDelegate = self
        
        print(indexPath.row)
        
        if tableView == classTableView {
            // if searchNoView needs to be withdrawn, pass currentTable name to cell and add a parameter to the delegate action which passes the currentTable which is in view.
            cell.currentTableView = classTableView
            cell.nameLabel.text = currentClassModelArray[indexPath.row].student_name ?? ""
            cell.idLabel.text = "\(currentClassModelArray[indexPath.row].student_id ?? 0 )"
            if currentClassModelArray[indexPath.row].evacuated == 0 {
                cell.mySwitch.isOn = false
                cell.myLabel.text = "A"
                cell.myLabel.backgroundColor = UIColor(red: 234.0 / 255.0, green: 48.0 / 255.0, blue: 86.0 / 255.0, alpha: 1.0)
//                cell.myLabel.backgroundColor = UIColor.red
            }
            else
            {
            if currentClassModelArray[indexPath.row].evacuated == 1 {
                cell.mySwitch.isOn = true
                cell.myLabel.text = "P"
                cell.myLabel.backgroundColor = UIColor(red: 78.0 / 255.0, green: 203.0 / 255.0, blue: 113.0 / 255.0, alpha: 1.0)
//                cell.myLabel.backgroundColor = UIColor.green
                }
            }
        }
        else if tableView == schoolTableView {
            cell.currentTableView = schoolTableView
            cell.nameLabel.text = schoolDataModelArray[indexPath.row].student_name ?? ""
            cell.idLabel.text = "\(schoolDataModelArray[indexPath.row].student_id ?? 0 )"
            if schoolDataModelArray[indexPath.row].evacuated == 0 {
                cell.mySwitch.isOn = false
                cell.myLabel.text = "A"
                cell.myLabel.backgroundColor = UIColor(red: 234.0 / 255.0, green: 48.0 / 255.0, blue: 86.0 / 255.0, alpha: 1.0)
//                cell.myLabel.backgroundColor = UIColor.red
            }else{
                if schoolDataModelArray[indexPath.row].evacuated == 1 {
                    cell.mySwitch.isOn = true
                    cell.myLabel.text = "P"
                    cell.myLabel.backgroundColor = UIColor(red: 78.0 / 255.0, green: 203.0 / 255.0, blue: 113.0 / 255.0, alpha: 1.0)
//                    cell.myLabel.backgroundColor = UIColor.green
                }
            }
        }
        else if tableView == searchTableView {
            cell.currentTableView = searchTableView
            let cellData = filteredData[indexPath.row]
            cell.nameLabel.text = cellData.student_name
            cell.idLabel.text = "\(cellData.student_id ?? 0)"
            if filteredData[indexPath.row].evacuated == 0 {
                cell.mySwitch.isOn = false
                cell.myLabel.text = "A"
                cell.myLabel.backgroundColor = UIColor(red: 234.0 / 255.0, green: 48.0 / 255.0, blue: 86.0 / 255.0, alpha: 1.0)
//                cell.myLabel.backgroundColor = UIColor.red
            }else{
                if filteredData[indexPath.row].evacuated == 1 {
                    cell.mySwitch.isOn = true
                    cell.myLabel.text = "P"
                    cell.myLabel.backgroundColor = UIColor(red: 78.0 / 255.0, green: 203.0 / 255.0, blue: 113.0 / 255.0, alpha: 1.0)
//                    cell.myLabel.backgroundColor = UIColor.green
                }
            }
//            return cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60

    }
    
    
    @objc func handlePanGesture(sender: UIPanGestureRecognizer) {
        switch sender.state{
        case.began:
            break
        case.ended:
            break
        default:
            break
        }
    }
}


extension Attendance: AttendanceTableViewProtocol {
    
    func onSwitchAction(indexValue: Int, flagIsOn: Bool, currentTableView: UITableView?) {
        
        let evacuateValue = flagIsOn ? 1 : 0
        
        if let currentTableView = currentTableView {
            
            self.currentTable = currentTableView
        }
        
        if currentTable == schoolTableView {
            if flagIsOn == true {
                self.schoolDataModelArray[indexValue].evacuated = 1
                if let studentIDInt = schoolDataModelArray[indexValue].student_id {
                    self.evacuationStudentsRef.child("\(studentIDInt)").updateChildValues(["evacuated" : evacuateValue, "evacuated_by" : DefaultWrapper.shared.staffName, "evacuated_assembly_points" : DefaultWrapper.shared.assemblypoint])
                }
            }else {
                self.schoolDataModelArray[indexValue].evacuated = 0
                if let studentIDInt = schoolDataModelArray[indexValue].student_id {
                    self.evacuationStudentsRef.child("\(studentIDInt)").updateChildValues(["evacuated" : evacuateValue, "evacuated_by" : "", "evacuated_assembly_points" : ""])
                }
            }
//            if let studentIDInt = schoolDataModelArray[indexValue].student_id {
//                self.evacuationStudentsRef.child("\(studentIDInt)").updateChildValues(["evacuated" : evacuateValue, "evacuated_by" : DefaultWrapper.shared.staffName, "evacuated_assembly_points" : DefaultWrapper.shared.assemblypoint])
//            }
            
        }
        else if currentTable == classTableView {
            
            if flagIsOn == true {
                self.currentClassModelArray[indexValue].evacuated = 1
                if let studentIDInt = currentClassModelArray[indexValue].student_id {
                    self.evacuationStudentsRef.child("\(studentIDInt)").updateChildValues(["evacuated" : evacuateValue, "evacuated_by" : DefaultWrapper.shared.staffName, "evacuated_assembly_points" : DefaultWrapper.shared.assemblypoint])
                }
            }else {
                self.currentClassModelArray[indexValue].evacuated = 0
                if let studentIDInt = currentClassModelArray[indexValue].student_id {
                    self.evacuationStudentsRef.child("\(studentIDInt)").updateChildValues(["evacuated" : evacuateValue, "evacuated_by" : "", "evacuated_assembly_points" : ""])
                }
            }
//            if let studentIDInt = currentClassModelArray[indexValue].student_id {
//                self.evacuationStudentsRef.child("\(studentIDInt)").updateChildValues(["evacuated" : evacuateValue, "evacuated_by" : DefaultWrapper.shared.staffName, "evacuated_assembly_points" : DefaultWrapper.shared.assemblypoint])
//            }
        }
        else if currentTable == searchTableView {
            
            if flagIsOn == true {
                self.filteredData[indexValue].evacuated = 1
                if let studentIDInt = filteredData[indexValue].student_id {
                    self.evacuationStudentsRef.child("\(studentIDInt)").updateChildValues(["evacuated" : evacuateValue, "evacuated_by" : DefaultWrapper.shared.staffName, "evacuated_assembly_points" : DefaultWrapper.shared.assemblypoint])
                }
            }else {
                self.filteredData[indexValue].evacuated = 0
                if let studentIDInt = filteredData[indexValue].student_id {
                    self.evacuationStudentsRef.child("\(studentIDInt)").updateChildValues(["evacuated" : evacuateValue, "evacuated_by" : "", "evacuated_assembly_points" : ""])
                }
            }
//            if let studentIDInt = filteredData[indexValue].student_id {
//                self.evacuationStudentsRef.child("\(studentIDInt)").updateChildValues(["evacuated" : evacuateValue, "evacuated_by" : DefaultWrapper.shared.staffName, "evacuated_assembly_points" : DefaultWrapper.shared.assemblypoint])
//            }
        }
        
}
}

extension Attendance: UISearchBarDelegate {


       // MARK: - UISearchBarDelegate

       func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

       }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchText = searchBar.text else { return }

        filteredData = []
        
//        currentTable = searchTableView
        
        // Filter the data array based on the search text
        filteredData = schoolDataModelArray.filter { ($0.student_name ?? "").localizedCaseInsensitiveContains(searchText) || String($0.student_id ?? 0).localizedCaseInsensitiveContains(searchText) }

        let newHeight = 60 * filteredData.count
        
        if newHeight < 200 {
        searchViewHeightConstraint.constant = CGFloat(60 * filteredData.count)
        }else {
            searchViewHeightConstraint.constant = 200
        }
        // Reload the table view with the filtered data
        searchTableView.reloadData()
    }

   struct CellData {
       let name: String
       // Additional properties for each cell's data
   }
}

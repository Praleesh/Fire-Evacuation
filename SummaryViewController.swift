//
//  SummaryViewController.swift
//  FireEvacuation
//
//  Created by FAO on 29/05/23.
//

import UIKit
import Firebase
import FirebaseDatabase

class SummaryViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sessionLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var assemblyPointLabel: UILabel!
    
    @IBOutlet weak var totalStudentsLabel: UILabel!
    @IBOutlet weak var studentsEvacuatedLabel: UILabel!
    @IBOutlet weak var studentsNotFoundLabel: UILabel!
    @IBOutlet weak var summaryBgView: UIView!
    
    @IBOutlet weak var currentClassLabel: UILabel!
    @IBOutlet weak var othersLabel: UILabel!
    
    var successfulCount = 0
    
    var currentClassEvacuated = 0
    
    let evacuationStudentsRef = Database.database().reference().child("evacuation_students").child("\(DefaultWrapper.shared.evacuationid)")
    
    var schoolModelArray = [SchoolDataModel]()
    
    var currentModelArray = [ClassCurrentModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.summaryBgView.layer.cornerRadius = 10
        summaryBgView.layer.masksToBounds = true
        
        
        
        evacuationStudentsRef.observe(.value, with: { [self] (snapshot) in
            
            print(snapshot)
            
            let studentsCount = snapshot.childrenCount
            
            print("Child node count: \(studentsCount)")
            
            self.schoolModelArray = []
            
            var successfulCount = 0    // for getting students evacuated value
            
            for case let child as DataSnapshot in snapshot.children {
                let student_name = child.childSnapshot(forPath: "student_name").value as? String ?? ""
                let student_id = child.childSnapshot(forPath: "student_id").value as? Int ?? 0
                let student_class_section = child.childSnapshot(forPath: "student_class_section").value as? String ?? ""
                let evacuated = child.childSnapshot(forPath: "evacuated").value as? Int ?? 0
                let temp = SchoolDataModel(student_name: student_name, student_id: student_id, student_class_section: student_class_section, evacuated: evacuated)
                self.schoolModelArray.append(temp)
            }
            
            DefaultWrapper.shared.totalstudents = schoolModelArray.count
            print("total students in school: \(DefaultWrapper.shared.totalstudents)")
            successfulCount = 0
            for i in schoolModelArray.indices {
                if schoolModelArray[i].evacuated == 1 {
                    successfulCount += 1
                }
            }
            DefaultWrapper.shared.studentsEvacuated = successfulCount
            print("students evacuated count: \(DefaultWrapper.shared.studentsEvacuated)")
            
            self.dateLabel.text = DefaultWrapper.shared.date
            self.sessionLabel.text = DefaultWrapper.shared.classname
            self.subjectLabel.text = DefaultWrapper.shared.subject
            self.totalStudentsLabel.text = "\(DefaultWrapper.shared.totalstudents)"
            self.studentsEvacuatedLabel.text = "\(DefaultWrapper.shared.studentsEvacuated)"
            self.studentsNotFoundLabel.text = "\(DefaultWrapper.shared.totalstudents - DefaultWrapper.shared.studentsEvacuated)"
            self.assemblyPointLabel.text = DefaultWrapper.shared.assemblypoint
            
            self.currentModelArray = []
            
            for student in self.schoolModelArray {
                if DefaultWrapper.shared.classname.contains(student.student_class_section ?? "") {
                    // append to current class array
                    let student_name = student.student_name ?? ""
                    let student_id = student.student_id ?? 0
                    let student_class_section = student.student_class_section ?? ""
                    let evacuated = student.evacuated ?? 0
                    let temp = ClassCurrentModel(student_name: student_name, student_id: student_id, student_class_section: student_class_section, evacuated: evacuated)
                    self.currentModelArray.append(temp)
                }
            }
            
            currentClassEvacuated = 0
            for i in currentModelArray.indices {
                if currentModelArray[i].evacuated == 1 {
                    currentClassEvacuated += 1
                }
            }
            self.currentClassLabel.text = "Current Class : \(currentClassEvacuated)"
            self.othersLabel.text = "Others : \(DefaultWrapper.shared.studentsEvacuated - currentClassEvacuated)"
        })
        { (error) in
            print("Error: \(error.localizedDescription)")
        }
    }
            @IBAction func backButtonPressed(_ sender: UIButton) {
                navigationController?.popViewController(animated: true)
            }
            
        }

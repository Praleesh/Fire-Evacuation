//
//  EvacuationProgressVc.swift
//  FireEvacuation
//
//  Created by FAO on 12/05/23.
//

import UIKit
import Firebase
import FirebaseDatabase


class EvacuationProgressVc: UIViewController {
    
    var cp = CircularProgressView()
    
    @IBOutlet weak var ProgressView: UIView!
    
    @IBOutlet weak var endEvacuationView: UIView!

    var EVACUATIONEND = API_Manager().Header + API_Manager().evacuationend
    var EVACUATIONSTATUS = API_Manager().Header + API_Manager().evacuationstatus
    
    var evacuationEndModel: EvacuationEndModel?
    var evacuationStatusModel = [EvacuationStatusModel]()
    
    var progressViewSchoolModelArray = [ProgressViewSchoolModel]()
    var progressViewClassModelArray = [ProgressViewClassModel]()
    
    @IBOutlet weak var percentageLabel: UILabel!
    
//    var name: String = "a"
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // alert
    @IBOutlet weak var AlertMessageLabel: UILabel!
    @IBOutlet weak var imageinView: UIView!
    @IBOutlet weak var bgtop: UIView!
    @IBOutlet weak var bgPopup: UIView!
    @IBOutlet weak var bgAlertView: UIView!
    
    
    let evacuationStudentsRef = Database.database().reference().child("evacuation_students").child("\(DefaultWrapper.shared.evacuationid)")
    
    var successfulCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.CircularProgress.isHidden = false
        
        setupProgressView()
        
        self.bgPopup.layer.cornerRadius = 15
        self.bgtop.layer.cornerRadius = 35
        self.imageinView.layer.cornerRadius = 32
        self.AlertMessageLabel.text = "Evacuation Completed"
        
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        self.bgAlertView.isHidden = true
        
        self.endEvacuationView.layer.cornerRadius = 28
        self.endEvacuationView.layer.masksToBounds = true
        
        evacuationStudentsRef.observe(.value, with: { [self] (snapshot) in
            
            print(snapshot)
            
            let studentsCount = snapshot.childrenCount
             
            print("Child node count: \(studentsCount)")
            
            self.progressViewSchoolModelArray = []
            
            for case let child as DataSnapshot in snapshot.children {
                        let student_name = child.childSnapshot(forPath: "student_name").value as? String ?? ""
                        let student_id = child.childSnapshot(forPath: "student_id").value as? Int ?? 0
                        let student_class_section = child.childSnapshot(forPath: "student_class_section").value as? String ?? ""
                        let evacuated = child.childSnapshot(forPath: "evacuated").value as? Int ?? 0
                let temp = ProgressViewSchoolModel(student_name: student_name, student_id: student_id, student_class_section: student_class_section, evacuated: evacuated)
                        self.progressViewSchoolModelArray.append(temp)
                    }
            
            DefaultWrapper.shared.totalstudents = progressViewSchoolModelArray.count
            print("total students in school: \(DefaultWrapper.shared.totalstudents)")
            successfulCount = 0
            for i in progressViewSchoolModelArray.indices {
                if progressViewSchoolModelArray[i].evacuated == 1 {
                    successfulCount += 1
                }
            }
            DefaultWrapper.shared.studentsEvacuated = successfulCount
            print("students evacuated count: \(DefaultWrapper.shared.studentsEvacuated)")
            
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            
            self.perform(#selector(animateProgress), with: nil, afterDelay: 0.0)
        })
        { (error) in
            print("Error: \(error.localizedDescription)")
            Common.alert(alertMessageParameter: "some error occured")
        }
    }

            
    func setupProgressView() {
             cp = CircularProgressView(frame:CGRect(x: 0, y: 0, width: ProgressView.bounds.width, height: ProgressView.bounds.height))
            cp.frame = ProgressView.bounds
            cp.trackColor = UIColor(
                red: CGFloat(0xEA) / 255.0,
                green: CGFloat(0x30) / 255.0,
                blue: CGFloat(0x56) / 255.0,
                alpha: 1.0
            )
            cp.progressColor = UIColor(
                red: CGFloat(0x4E) / 255.0,
                green: CGFloat(0xCB) / 255.0,
                blue: CGFloat(0x71) / 255.0,
                alpha: 1.0
            )
            cp.tag = 101
            self.ProgressView.addSubview(cp)

        }
        

    
     @objc func animateProgress() {
        
        let cP = self.view.viewWithTag(101) as! CircularProgressView

        let maxValue = DefaultWrapper.shared.totalstudents
        let currentValue = DefaultWrapper.shared.studentsEvacuated

        let progress = Float(currentValue) / Float(maxValue)
        
        cP.setProgressWithAnimation(duration: 1.0, value: Float(progress))

        let percentage = Int(Float((Float(currentValue) / Float(maxValue)) * 100))
        
//        self.percentageLabel.text = "\(percentage)"
        self.percentageLabel.text = "\(currentValue)"

        print("The percentage is: \(percentage) %")
        
        //        cP.setProgressWithAnimation(duration: 1.0, value: 0.7)
        
    }
    

    @IBAction func didEvacuationEndButtonTapped(_ sender: UIButton) {
        ProgressView.isHidden = true
        self.bgAlertView.isHidden = false
        self.makeNetworkCallForEvacuationEnd()
//        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didBackButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didAlertOkButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
  
//    func navigateToEvacuationEndAlert() {
//
//        let strybrd = UIStoryboard(name: "EvacuationEndAlert", bundle: nil)
//        let nexVc = strybrd.instantiateViewController(withIdentifier: "EvacuationEndViewController") as! EvacuationEndViewController
//        nexVc.modalTransitionStyle = .crossDissolve
//        nexVc.modalPresentationStyle = .overFullScreen
//        present(nexVc, animated: true, completion: nil)
////        navigationController?.pushViewController(nexVc, animated: true)
//    }
    
}

extension EvacuationProgressVc {

    // MARK: - EVACUATION END
    
    func makeNetworkCallForEvacuationEnd() {
        
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        guard let urlData = URL(string: EVACUATIONEND) else { return }
        var req = URLRequest(url: urlData)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(DefaultWrapper.shared.tokengenerated)", forHTTPHeaderField: "Authorization")
        req.httpMethod = "POST"
        let parameters: [String: Any] = [
            "evacuate_id": DefaultWrapper.shared.evacuationid
        ]
        do {
            let body = try JSONSerialization.data(withJSONObject: parameters, options: [])
            req.httpBody = body
        }catch {
            print("Error")
        }
        let session = URLSession.shared
        session.dataTask(with: req) { responsedata, urlresponse, err in
            print("evacuation end evacuation_id: \(DefaultWrapper.shared.evacuationid)")
            if let error = err {
                print(error)
                Common.alert(alertMessageParameter: "some error occured")
                return
            }
            
            if let dataInByte = responsedata {
                print("EvacuationEnd datainbyte\(dataInByte)")
                
                if let jsonConv = responsedata {
                    do {
                        
                        let json = try JSONSerialization.jsonObject(with: jsonConv)
                        print("EvacuationEnd json: \(json)")
                        
                         if let conv = json as? [String: Any] {
                            print("EvacuationEnd conv:\(conv)")
                             
                             if let successKey = conv["success"] as? Bool {
                                 print(successKey)
                                 
                                 DispatchQueue.main.async {
                                     self.evacuationEndModel = EvacuationEndModel(fromdata: conv)
                                     self.activityIndicator.stopAnimating()
                                     self.activityIndicator.isHidden = true
////                                     self.navigateToMartialViewController()
//                                     self.navigateToEvacuationEndAlert()
                                 }
                             }
                        }
                    }catch {
                        print("error")
                    }
                }
            }
        }.resume()
    }
}

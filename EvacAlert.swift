//
//  EvacAlert.swift
//  FireEvacuation
//
//  Created by FAO on 05/05/23.
//

import UIKit

class EvacAlert: UIViewController {
    
    var EVACUATIONSTART = API_Manager().Header + API_Manager().evacuationstart
    var SENDSTAFFNOTIFICATION = API_Manager().Header + API_Manager().sendstaffnotification
    
    @IBOutlet weak var popTopView: UIView!
    @IBOutlet weak var imageInView: UIView!
    @IBOutlet weak var popTopImageView: UIImageView!
    @IBOutlet weak var panLabel1: UILabel!
    @IBOutlet weak var panLabel2: UILabel!
    @IBOutlet weak var panLabel3: UILabel!
    
    @IBOutlet weak var newView: UIView!
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var panview1: UIView!
    @IBOutlet weak var panview2: UIView!
    @IBOutlet weak var panview3: UIView!
    
    @IBOutlet weak var movableView1: UIView!
    @IBOutlet weak var movableView2: UIView!
    @IBOutlet weak var movableView3: UIView!
    
    var panGesture1: UIPanGestureRecognizer!
    var panGesture2: UIPanGestureRecognizer!
    var panGesture3: UIPanGestureRecognizer!
    
    var initialViewPosition1: CGPoint!
    var initialViewPosition2: CGPoint!
    var initialViewPosition3: CGPoint!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var showAlertOnSucess: ((String) -> Void)?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
        
        self.newView.layer.cornerRadius = 15
        
        self.panview1.layer.cornerRadius = 15
        self.panview2.layer.cornerRadius = 15
        self.panview3.layer.cornerRadius = 15
        self.movableView1.layer.cornerRadius = 15
        self.movableView2.layer.cornerRadius = 15
        self.movableView3.layer.cornerRadius = 15
        
        // Do any additional setup after loading the view.
        
        // MARK: - pan gesture
        let panGesture1 = UIPanGestureRecognizer(target: self, action: #selector(handlePan1(_:)))
        movableView1.addGestureRecognizer(panGesture1)
        
        let panGesture2 = UIPanGestureRecognizer(target: self, action: #selector(handlePan2(_:)))
        movableView2.addGestureRecognizer(panGesture2)
        
        let panGesture3 = UIPanGestureRecognizer(target: self, action: #selector(handlePan3(_:)))
        movableView3.addGestureRecognizer(panGesture3)
        
        initialViewPosition1 = movableView1.center
        initialViewPosition2 = movableView2.center
        initialViewPosition3 = movableView3.center
        
        self.imageInView.layer.cornerRadius = 25
        self.popTopView.layer.cornerRadius = 30
        
        self.makeNetworkCallForSendStaffNotification()
    }
    
    @IBAction func DidTapButtonToDismiss() {
       dismiss(animated: true)
    }
    
    @objc func handlePan1(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: panview1)
        
        let newXPosition = max(min(movableView1.center.x + translation.x, panview1.bounds.width - movableView1.bounds.width / 2), movableView1.bounds.width / 2)
        let newYPosition = movableView1.center.y
        
        movableView1.center = CGPoint(x: newXPosition, y: newYPosition)
        
        gesture.setTranslation(.zero, in: panview1)
        
        if newXPosition == movableView1.bounds.width / 2 && gesture.state == .ended {
            // The view is at the left end of the pan view
        }
        
        if gesture.state == .ended {
            if newXPosition == panview1.bounds.width - movableView1.bounds.width / 2 {
                UIView.animate(withDuration: 0.1) {
//                    self.navigateToEvacuationProgressVc()
                    self.panview1.alpha = 0
                    self.makeNetworkCallForEvacuationStartFire()
                    
                }
            } else {
                // Reset the movable view's position and show the label again
                UIView.animate(withDuration: 0.1) {
                    self.movableView1.center = self.initialViewPosition1
                    self.panLabel1.alpha = max(0, 1 - (newXPosition - self.movableView1.bounds.width / 2) / (self.panview1.bounds.width - self.movableView1.bounds.width))
                }
            }
        }
    }
    
    @objc func handlePan2(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: panview2)
        
        let newXPosition = max(min(movableView2.center.x + translation.x, panview2.bounds.width - movableView2.bounds.width / 2), movableView2.bounds.width / 2)
        let newYPosition = movableView2.center.y
        
        movableView2.center = CGPoint(x: newXPosition, y: newYPosition)
        
        gesture.setTranslation(.zero, in: panview2)
        
        if newXPosition == movableView2.bounds.width / 2 && gesture.state == .ended {
            
            // The view is at the left end of the pan view
        }
        
        if gesture.state == .ended {
            if newXPosition == panview2.bounds.width - movableView2.bounds.width / 2 {
                // The view is at the right end of the pan view
                self.makeNetworkCallForEvacuationStartBomb()
                panview2.alpha = 0
//                self.navigateToEvacuationProgressVc()
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.movableView2.center = self.initialViewPosition2
                }
            }
        }
    }
    
    @objc func handlePan3(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: panview3)
        
        let newXPosition = max(min(movableView3.center.x + translation.x, panview3.bounds.width - movableView3.bounds.width / 2), movableView3.bounds.width / 2)
        let newYPosition = movableView3.center.y
        
        movableView3.center = CGPoint(x: newXPosition, y: newYPosition)
        
        gesture.setTranslation(.zero, in: panview3)
        
        if newXPosition == movableView3.bounds.width / 2 && gesture.state == .ended {
            // The view is at the left end of the pan view
        }
        
        if gesture.state == .ended {
            if newXPosition == panview3.bounds.width - movableView3.bounds.width / 2 {

                self.makeNetworkCallForEvacuationStartEmergency()
                    panview3.alpha = 0
                
                
//                self.navigateToEvacuationProgressVc()
                // The view is at the right end of the pan view
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.movableView3.center = self.initialViewPosition3
                }
            }
        }
    }
    
//    func navigateToEvacuationProgressVc() {
//        // Your navigation code here
//        let storyBrd = UIStoryboard(name: "Main", bundle: nil)
//        let signVc = storyBrd.instantiateViewController(withIdentifier: "EvacuationProgressVc") as! EvacuationProgressVc
//        signVc.modalTransitionStyle = .crossDissolve
//        signVc.modalPresentationStyle = .overFullScreen
//        navigationController?.pushViewController(signVc, animated: true)
////        self.present(signVc, animated: true)
//    }
    
    //MARK: - EVACUATION START FIRE
    
    func makeNetworkCallForEvacuationStartFire() {
        
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        guard let url = URL(string: EVACUATIONSTART) else { return }
        
        let parameters: [String:Any] = ["evacuate_type": "Fire"]
        
        var urlRequest = URLRequest(url: url)
        do{
            let body = try JSONSerialization.data(withJSONObject: parameters)
            urlRequest.httpBody = body
        }catch
        {
            print("error")
        }
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(DefaultWrapper.shared.tokengenerated)", forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        session.dataTask(with: urlRequest) { (datainbyte, responseinbyte, errorinbyte) in
            if let error = errorinbyte
            {
                print("error \(error.localizedDescription)")
            }
            if let dataConv = datainbyte {
                do
                {
                    let jsondata = try JSONSerialization.jsonObject(with: dataConv, options: [])
                    //                    print("jsondata: \(jsondata)")
                    if let json = jsondata as? [String: Any]{
                        print("EvacuationStart json: \(json)")
                        if let statusKey = json["status"] as? Int {
                            print(statusKey)
                            if let messageKey = json["message"] as? String {
                                print(messageKey)
                                DispatchQueue.main.async {
                                    self.activityIndicator.isHidden = true
                                    self.activityIndicator.stopAnimating()
                                    if statusKey == 200 {
                                        print("success")
                                        if let dataInJson = json["data"] as? [String: Any] {
                                            print("dataInJson: \(dataInJson)")
                                            if let getKey = dataInJson["get_key"] as? String {
                                                DefaultWrapper.shared.evacuationid = getKey
                                            }
                                        }
                                        self.dismiss(animated: true)
                                        self.showAlertOnSucess?(messageKey)
                                        
                                        
//                                        Common.EvacuationAlerted(alertMessageParameter: messageKey)
                                    } else {
                                        print("failed")
                                        self.dismiss(animated: true)
                                        self.showAlertOnSucess?(messageKey)
                                        
//                                        Common.EvacuationAlerted(alertMessageParameter: messageKey)
                                        
                                    }
                                }
                            }
                        }
                    }
                }catch
                {
                    print("error")
                    Common.alert(alertMessageParameter: "Some Error Occured")
                }
            }
        }.resume()
        
    }//MARK: - EVACUATION START BOMB
    
    func makeNetworkCallForEvacuationStartBomb(){
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        guard let url = URL(string: EVACUATIONSTART) else { return }
        
        let parameters: [String:Any] = ["evacuate_type": "Bomb"]
        
        var urlRequest = URLRequest(url: url)
        do{
            let body = try JSONSerialization.data(withJSONObject: parameters)
            urlRequest.httpBody = body
        }catch
        {
            print("error")
        }
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(DefaultWrapper.shared.tokengenerated)", forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        session.dataTask(with: urlRequest) { (datainbyte, responseinbyte, errorinbyte) in
            if let error = errorinbyte
            {
                print("error \(error.localizedDescription)")
            }
            if let dataConv = datainbyte {
                do
                {
                    let jsondata = try JSONSerialization.jsonObject(with: dataConv, options: [])
                    //                    print("jsondata: \(jsondata)")
                    if let json = jsondata as? [String: Any]{
                        print("json: \(json)")
                        if let statusKey = json["status"] as? Int {
                            print(statusKey)
                            if let messageKey = json["message"] as? String {
                                print(messageKey)
                                DispatchQueue.main.async {
                                    self.activityIndicator.isHidden = true
                                    self.activityIndicator.stopAnimating()
                                    if statusKey == 200 {
                                        print("success")
                                        if let dataInJson = json["data"] as? [String: Any] {
                                            print("dataInJson: \(dataInJson)")
                                            if let getKey = dataInJson["get_key"] as? String {
                                                DefaultWrapper.shared.evacuationid = getKey
                                            }
                                        }
                                        self.dismiss(animated: true)
                                        self.showAlertOnSucess?(messageKey)
                
//                                        Common.EvacuationAlerted(alertMessageParameter: messageKey)
                                    } else {
                                        print("failed")
                                        self.dismiss(animated: true)
                                        self.showAlertOnSucess?(messageKey)
                                        
//                                        Common.EvacuationAlerted(alertMessageParameter: messageKey)
                                    }
                                }
                            }
                        }
                    }
                }catch
                {
                    print("error")
                    Common.alert(alertMessageParameter: "Some Error Occured")
                }
            }
        }.resume()
        
    }//MARK: - EVACUATION START EMERGENCY
    
    func makeNetworkCallForEvacuationStartEmergency() {
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        guard let url = URL(string: EVACUATIONSTART) else { return }
        
        let parameters: [String:Any] = ["evacuate_type": "Emergency"]
        
        var urlRequest = URLRequest(url: url)
        do{
            let body = try JSONSerialization.data(withJSONObject: parameters)
            urlRequest.httpBody = body
        }catch
        {
            print("error")
        }
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(DefaultWrapper.shared.tokengenerated)", forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        session.dataTask(with: urlRequest) { (datainbyte, responseinbyte, errorinbyte) in
            if let error = errorinbyte
            {
                print("error \(error.localizedDescription)")
            }
            if let dataConv = datainbyte {
                do
                {
                    let jsondata = try JSONSerialization.jsonObject(with: dataConv, options: [])
                    //                    print("jsondata: \(jsondata)")
                    if let json = jsondata as? [String: Any]{
                        print("json: \(json)")
                        if let statusKey = json["status"] as? Int {
                            print(statusKey)
                            if let messageKey = json["message"] as? String {
                                print(messageKey)
                                DispatchQueue.main.async {
                                    self.activityIndicator.isHidden = true
                                    self.activityIndicator.stopAnimating()
                                    if statusKey == 200 {
                                        print("success")
                                        if let dataInJson = json["data"] as? [String: Any] {
                                            print("dataInJson: \(dataInJson)")
                                            if let getKey = dataInJson["get_key"] as? String {
                                                DefaultWrapper.shared.evacuationid = getKey
                                            }
                                        }
                                        self.dismiss(animated: true)
                                        self.showAlertOnSucess?(messageKey)
                                        
//                                        Common.EvacuationAlerted(alertMessageParameter: messageKey)
                                    } else {
                                        print("failed")
                                        self.dismiss(animated: true)
                                        self.showAlertOnSucess?(messageKey)
                                        
//                                        Common.EvacuationAlerted(alertMessageParameter: messageKey)
                                    }
                                }
                            }
                        }
                    }
                }catch
                {
                    print("error")
                    Common.alert(alertMessageParameter: "Some Error Occured")
                }
            }
        }.resume()
        
    }
    
    //MARK: - SEND STAFF NOTIFICATION
    
    func makeNetworkCallForSendStaffNotification(){
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        guard let url = URL(string: SENDSTAFFNOTIFICATION) else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(DefaultWrapper.shared.tokengenerated)", forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        session.dataTask(with: urlRequest) { (datainbyte, responseinbyte, errorinbyte) in
            if let error = errorinbyte
            {
                print("error \(error.localizedDescription)")
            }
            if let dataConv = datainbyte {
                do
                {
                    let jsondata = try JSONSerialization.jsonObject(with: dataConv, options: [])
                    print("jsondata: \(jsondata)")
                    
                    if let json = jsondata as? [String: Any]{
                        print("json: \(json)")
                        DispatchQueue.main.async {
                            self.activityIndicator.isHidden = true
                            self.activityIndicator.stopAnimating()
                        }
                    }
                }catch
                {
                    print("error")
                    Common.alert(alertMessageParameter: "Some Error Occured")
                }
            }
        }.resume()
        
    }
    
}

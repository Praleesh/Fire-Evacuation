//
//  martialViewController.swift
//  FireEvacuation
//
//  Created by Amritha on 02/05/23.
//

import UIKit


class MartialViewController: UIViewController, CAAnimationDelegate, UIScrollViewDelegate {
    
    var SESSIONOUT = API_Manager().Header + API_Manager().sessionout
    var EVACUATIONSTATUS = API_Manager().Header + API_Manager().evacuationstatus
    
    var evacuationStatusModelArray = [EvacuationStatusModel]()
    
    @IBOutlet weak var evacView: UIView!
    var rippleView: UIView!
    
    @IBOutlet weak var goodmorninglabel: UILabel!
    var timer: Timer?
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var movableView: UIView!
    var panGesture: UIPanGestureRecognizer!
    @IBOutlet weak var panview: UIView!
    var initialViewPosition: CGPoint!
    
    @IBOutlet weak var comingSoonLabel: UILabel!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.comingSoonLabel.isHidden = true
        self.comingSoonLabel.layer.cornerRadius = 5
        comingSoonLabel.layer.masksToBounds = true
        
       DefaultWrapper.shared.evacuationid = ""
        
        activityIndicator.isHidden = true
        
        self.panview.layer.cornerRadius = 5
        self.panview.layer.masksToBounds = true
        self.movableView.layer.cornerRadius = 5
        self.movableView.layer.masksToBounds = true

        
        // MARK:- pan gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        movableView.addGestureRecognizer(panGesture)
        initialViewPosition = movableView.center
        
        self.evacView.layer.cornerRadius = 100
        
        //  Start the timer when the view loads
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateLabel), userInfo: nil, repeats: true)
        
        nameLabel.text = DefaultWrapper.shared.staffName
        
        tabBarItem.image = UIImage(named: "FireFighterHelmet")?.withRenderingMode(.alwaysOriginal)
        
        // Set the selected image for the tab bar item
        tabBarItem.selectedImage = UIImage(named: "FireFighterHelmetSelected")?.withRenderingMode(.alwaysOriginal)
        
        self.makeNetworkCallForEvacuationStatus()
    }
    
    @IBAction func didPastEvacuationButtonClicked() {
        self.navigateToPastEvacuation()
    }
    
    @IBAction func didEvacButtonTapped(_ sender: UIButton){
        self.navigateToEvacAlert()
    }
    
    @IBAction func didCheckedInStaffsButtonTapped() {
        comingSoonLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.comingSoonLabel.isHidden = true
        }
    }
    
    @IBAction func didExternalProviderStatusTapped() {
        comingSoonLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.comingSoonLabel.isHidden = true
        }
    }
    
    func navigateToEvacAlert () {
        let strybrd = UIStoryboard(name: "Main", bundle: nil)
        let newVc = strybrd.instantiateViewController(withIdentifier: "EvacAlert") as! EvacAlert
        newVc.modalTransitionStyle = .crossDissolve
        newVc.modalPresentationStyle = .overFullScreen
        newVc.showAlertOnSucess = { messageKey in
            
            Common.alertLogin(alertMessageParameter: messageKey) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let destinationViewController = storyboard.instantiateViewController(withIdentifier: "EvacuationProgressVc") as! EvacuationProgressVc
                destinationViewController.modalTransitionStyle = .crossDissolve
                destinationViewController.modalPresentationStyle = .overFullScreen
                // Ensure AlertViewController is presented before presenting destinationViewController
                self.present(destinationViewController, animated: true)
            }
            
        }
        self.present(newVc, animated: true, completion: nil)
    }
    
    func navigateToPastEvacuation() {
        let stryBrd = UIStoryboard(name: "Main", bundle: nil)
        let newVc = stryBrd.instantiateViewController(withIdentifier: "PastEvacuationsViewController") as! PastEvacuationsViewController
        newVc.evacuationStatusModelArray = self.evacuationStatusModelArray
        navigationController?.pushViewController(newVc, animated: true)
    }
    
    func navigateToFireMarshal() {
        // Your navigation code here
        print("Navigate to next view")
        let storyBrd = UIStoryboard(name: "Main", bundle: nil)
        DispatchQueue.main.async {
            let signVc = storyBrd.instantiateViewController(withIdentifier: "FireMarshal") as! FireMarshal
            self.navigationController?.pushViewController(signVc, animated: true)
        }
    }
    
    func navigateToEvacuationProgressVc() {
        // Your navigation code here
        let storyBrd = UIStoryboard(name: "Main", bundle: nil)
        let signVc = storyBrd.instantiateViewController(withIdentifier: "EvacuationProgressVc") as! EvacuationProgressVc
        self.navigationController?.pushViewController(signVc, animated: true)
    }
    
    // MARK: - pan-gesture
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: panview)
        
        let newXPosition = max(min(movableView.center.x + translation.x, panview.bounds.width - movableView.bounds.width / 2), movableView.bounds.width / 2)
        let newYPosition = movableView.center.y
        
        movableView.center = CGPoint(x: newXPosition, y: newYPosition)
        
        gesture.setTranslation(.zero, in: panview)
        
        if newXPosition == movableView.bounds.width / 2 && gesture.state == .ended {
            self.makeNetworkCallForSessionOut()
            DefaultWrapper.shared.signedIn = 4
            self.navigateToFireMarshal()
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
    
    //MARK: - SESSION OUT
    
    func makeNetworkCallForSessionOut() {
        
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
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
                    // print(json)
                }catch{
                    print("Error")
                    Common.alert(alertMessageParameter: "Some Error Occured")
                }
            }
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
            }
        }.resume()
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
    
    //MARK: - EVACUATION STATUS
    
    func makeNetworkCallForEvacuationStatus() {
        
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
                    
                    
                    if let jsonDict = json as? [String: Any] {
                        //                            print("jsonDict: \(jsonDict)")
                        
                        if let jsonConv = jsonDict["data"] as? [[String: Any]] {
                            //                                print("jsonConv: \(jsonConv)")
                            
                            for i in jsonConv {
                                self.evacuationStatusModelArray.append(EvacuationStatusModel(fromdata: i))
                                
                            }
                            for i in self.evacuationStatusModelArray {
                                if let status = i.status {
                                    
                                    if status == 1 {
                                        DefaultWrapper.shared.evacuationid = i.evacuate_id ?? ""
                                        print("evacuationid in evacuation status: \(DefaultWrapper.shared.evacuationid)")
                                    }
                                    else {
                                    }
                                }
                            }
                        }
                        
                    }
                }catch {
                    print("error")
                    Common.alert(alertMessageParameter: "Some Error Occured")
                }
            }
        }.resume()
    }
    
}

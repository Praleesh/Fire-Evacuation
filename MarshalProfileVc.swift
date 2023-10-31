//
//  MarshalProfileVc.swift
//  FireEvacuation
//
//  Created by FAO on 11/05/23.
//

import UIKit

class MarshalProfileVc: UIViewController {
    
    @IBOutlet weak var profilePicView: UIView!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var new_passwordTextField: UITextField!
    @IBOutlet weak var password_confirmationTextField: UITextField!
    
    @IBOutlet weak var popupChangePasswordView: UIView!
    
    @IBOutlet weak var comingSoonLabel: UILabel!
    
    @IBOutlet weak var staffNameLabel: UILabel!
    
    
    var logOutUrl = API_Manager().Header + API_Manager().logout
    
    var changePasswordUrl = API_Manager().Header + API_Manager().changepassword
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var popupBgView: UIView!
    @IBOutlet weak var popupAlertView: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.popupBgView.isHidden = true
        self.popupAlertView.isHidden = true
        
        self.comingSoonLabel.isHidden = true
        self.comingSoonLabel.layer.cornerRadius = 5
        comingSoonLabel.layer.masksToBounds = true

        activityIndicator.isHidden = true
        
        profilePicView.layer.cornerRadius = 75
        self.popupChangePasswordView.alpha = 0
        
        //Tab bar icon remove tint and appear as it is
        tabBarItem.image = UIImage(named: "Profile")?.withRenderingMode(.alwaysOriginal)

        // Set the selected image for the tab bar item
        tabBarItem.selectedImage = UIImage(named: "ProfileSelected")?.withRenderingMode(.alwaysOriginal)
        
        self.staffNameLabel.text = DefaultWrapper.shared.staffName
        
    }
    
    @IBAction func bgViewButtonTapped() {
        self.popupBgView.isHidden = true
        self.popupAlertView.isHidden = true
    }
    
    @IBAction func didCheckoutButtonTapped(_ sender: UIButton) {
        self.popupBgView.isHidden = false
        self.popupAlertView.isHidden = false
        DefaultWrapper.shared.signedIn = 0
    }
    
    @IBAction func didYesButtonTapped() {
        self.checkoutapicall()
        self.navigationToWelcome()
    }
    
    @IBAction func didNoButtonTapped() {
        self.popupBgView.isHidden = true
        self.popupAlertView.isHidden = true
    }
    
    @IBAction func didSettingsButtonTapped(_ sender: UIButton) {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func didNotificationButtonTapped(_ sender: UIButton) {
        comingSoonLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.comingSoonLabel.isHidden = true
        }
    }
    
    @IBAction func didChangePasswordButtonTapped(_ sender: UIButton) {
        comingSoonLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.comingSoonLabel.isHidden = true
        }

    }
    
    @IBAction func didSaveButtonClicked(_ sender: UIButton) {
        self.changePasswordApiCall()
        popupChangePasswordView.alpha = 0
    }
    
    // MARK: - CHECKOUT
    
    func checkoutapicall() {
        
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        guard let url = URL(string: logOutUrl) else { return }
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
                            print("Key: \(statusKey)")
                            if let messageKey = json["message"] as? String {
                                print("messageKey: \(messageKey)")
                            DispatchQueue.main.async {
                                self.activityIndicator.isHidden = true
                                self.activityIndicator.stopAnimating()
                                if statusKey == 200
                                    {
                                    print("success")
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
                
            }
                catch
                {
                    print("Error")
                }
            }
        }.resume()
    }
    
    func navigationToWelcome() {
        let stryBrd = UIStoryboard(name: "Main", bundle: nil)
        let newVc = stryBrd.instantiateViewController(withIdentifier: "Welcome") as! Welcome
        navigationController?.pushViewController(newVc, animated: true)
    }
    
    //MARK: - CHANGE PASSWORD
    
    func changePasswordApiCall() {
        
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        let url = URL(string: changePasswordUrl)
        var urlRequest = URLRequest(url: url!)
                urlRequest.httpMethod = "POST"
        let token = DefaultWrapper.shared.tokengenerated
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = ["password": passwordTextField.text ?? "", "new_password": passwordTextField.text ?? "", "password_confirmation": password_confirmationTextField.text ?? ""]
                do
                {
                    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                }
                catch
                {
                    print("error")
                }
        let session = URLSession.shared
        session.dataTask(with: urlRequest) { (datainbyte, responseinbyte, errorinbyte) in
            if let error = errorinbyte {
                print("error\(error.localizedDescription)")
            }
            
            if let jsonData = datainbyte {
                do{
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
                    print("\(json)")
                    
                    if let convDictionary = json as? [String: Any]{
                        print(convDictionary)
                        
                        if let statuskey = convDictionary["status"] as? Int{
                            DispatchQueue.main.async {
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.isHidden = true
                            if statuskey == 200{
                                if let datadict = convDictionary["data"] as? [String: Any]
                                {
                                    print("Data: \(datadict)")
                                }
                            }
                        }
                }
            }
                }catch{
                    print("Error")
                }
            }
        }.resume()
    }
       
    func navigateToNotificationVc() {
        let stryBrd = UIStoryboard(name: "Main", bundle: nil)
        let newVc = stryBrd.instantiateViewController(withIdentifier: "NotificationVc") as! NotificationVc
        navigationController?.pushViewController(newVc, animated: true)
    }
    }

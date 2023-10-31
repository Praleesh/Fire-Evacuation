//
//  sign-in.swift
//  FireEvacuation
//
//  Created by Amritha on 11/04/23.
//

import UIKit

class Sign_In: UIViewController {
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    @IBOutlet weak var emailtextField: UITextField!
    @IBOutlet weak var passwordtextField: UITextField!
    
    var mydata: String?
    
    var loginUrl = API_Manager().Header + API_Manager().login
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var isPasswordVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
        
        signInButton.layer.cornerRadius = 5
        signInButton.layer.masksToBounds = true
        createAccountButton.layer.cornerRadius = 5
        createAccountButton.layer.masksToBounds = true
        
        signInButton.isEnabled = false
        
        passwordtextField.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        emailtextField.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        emailtextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordtextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        self.emailtextField.keyboardType = .emailAddress
        self.emailtextField.autocorrectionType = .yes
        self.emailtextField.textContentType = .emailAddress

        self.passwordtextField.isSecureTextEntry = true
        self.passwordtextField.textContentType = .password
        
        self.tapgesture()
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Assuming you have a button with an IBOutlet named signInButton
        signInButton.isEnabled = !emailtextField.text!.isEmpty && !passwordtextField.text!.isEmpty
    }
    
    @objc func textFieldDidBeginEditing() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    @IBAction func showButtonClicked(_ sender: UIButton) {
        isPasswordVisible.toggle()
            passwordtextField.isSecureTextEntry = !isPasswordVisible
    }
    
    @IBAction func backbuttontapped (sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signInButtonTapped(sender:Any) {
//        guard emailtextField.text != "" else {
//            print("Email Required")
//            Common.alert(alertMessageParameter: "Please Enter Email")
//            //            Common.alertLogin(alertTitleParameter: "ALERT", alertMessageParameter: "Email Required")
//            return
//        }
//
//
//        guard passwordtextField.text != "" else {
//            print("Password Required")
//            Common.alertLogin(alertMessageParameter: "Password Required")
//            return
//        }
     
        self.loginApiCall()
    }
    
    @IBAction func createAccountButtonTapped(sender:Any) {
        let storyBrd = UIStoryboard(name: "Main", bundle: nil)
        let newVc = storyBrd.instantiateViewController(withIdentifier: "CreateAccount") as! CreateAccount
        self.navigationController?.pushViewController(newVc, animated: true)
    }
    
    //MARK: - SIGNIN API
    func loginApiCall() {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        let url = URL(string: loginUrl)
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = ["email": emailtextField.text ?? "", "password": passwordtextField.text ?? ""]
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                Common.alert(alertMessageParameter: "Some error occurred")
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
            return
        }
        
        let session = URLSession.shared
        session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    Common.alert(alertMessageParameter: "Some Error Occurred")
                }
                return
            }
            
            if let jsonData = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
                    if let convDictionary = json as? [String: Any] {
                        print("Array of Dictionary: \(convDictionary)")
                        if let successKey = convDictionary["success"] as? Bool {
                            print("successKey: \(successKey)")
                            if successKey == true {
                            if let dataKey = convDictionary["data"] as? [String: Any] {
                                print("dataKey: \(dataKey)")
                                if let staffId = dataKey["staff_id"] as? Int {
                                    print("staffid: \(staffId)")
                                    DefaultWrapper.shared.staffid = staffId
                                    if let tokenKey = dataKey["token"] as? String {
                                        print("tokenKey: \(tokenKey)")
                                        DefaultWrapper.shared.tokengenerated = tokenKey
                                        if let nameKey = dataKey["name"] as? String {
                                            print("nameKey: \(nameKey)")
                                            DefaultWrapper.shared.staffName = nameKey
                                            if let isMartialKey = dataKey["is_martial"] as? Int {
                                                print("ismartial: \(isMartialKey)")
                                                        if isMartialKey == 1 {
                                                            // Navigate to martial view controller
                                                            DefaultWrapper.shared.signedIn = 2
                                                            self.navigateToFireMarshal()
                                                        } else {
                                                            DefaultWrapper.shared.signedIn = 1
                                                            self.navigateToStaff()
                                                        }
                                                    }
                                            }
                                        }
                                    }
                                }
                            }else {
                                DispatchQueue.main.async {
                                self.activityIndicator.isHidden = true
                                self.activityIndicator.stopAnimating()
                                Common.alert(alertMessageParameter: "Invalid Credentials")
                                }
                            }
                        }
                    }
                } catch let err{
                    print(err.localizedDescription)
//                    print("Error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        Common.alert(alertMessageParameter: "An error occurred")
                    }
                }
            }
        }.resume()
    }
    
    func navigateToFireMarshal() {
        let strybrd = UIStoryboard(name: "Main", bundle: nil)
        DispatchQueue.main.async {
            let newVc = strybrd.instantiateViewController(withIdentifier: "FireMarshal") as! FireMarshal
            self.navigationController?.pushViewController(newVc, animated: true)
        }
        
    }
    func navigateToStaff() {
        let strybrd = UIStoryboard(name: "Main", bundle: nil)
        DispatchQueue.main.async {
        let newVc = strybrd.instantiateViewController(withIdentifier: "TabBar") as! TabBar
        self.navigationController?.pushViewController(newVc, animated: true)
        }
    }
    // MARK: - dismiss keyboard on tap
    func tapgesture()
    {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard()
    {
        // Resign first responder status of the text field
        emailtextField.resignFirstResponder()
        passwordtextField.resignFirstResponder()
    }
    
    func navigate() {
        let storyBrd = UIStoryboard(name: "Main", bundle: nil)
        let newVc = storyBrd.instantiateViewController(withIdentifier: "TabBar") as! TabBar
        self.navigationController?.pushViewController(newVc, animated: true)
    }
    
    @IBAction func didRecoverYourAccountButtonTapped(_ sender: UIButton) {
        let storyBrd = UIStoryboard(name: "Main", bundle: nil)
        let newVc = storyBrd.instantiateViewController(withIdentifier: "AlertController") as! AlertController
        newVc.modalPresentationStyle = .overFullScreen
        newVc.modalTransitionStyle = .crossDissolve
        self.present(newVc, animated: true, completion: nil)
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
}


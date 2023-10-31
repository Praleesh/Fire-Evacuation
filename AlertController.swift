//
//  alert_controller.swift
//  FireEvacuation
//
//  Created by Amritha on 28/04/23.
//

import UIKit

class AlertController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var popupview: UIView!
    @IBOutlet weak var submitButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
      
        popupview.layer.cornerRadius = 10
        submitButton.layer.cornerRadius = 10
        
        emailTextField.keyboardType = .emailAddress
    }
    
    func tapgesture()
    {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard()
    {
        self.emailTextField.resignFirstResponder()
    }
    
    @IBAction func didSubmitButtonTapped(_ sender: UIButton) {
        guard emailTextField.text != "" else {
            print("Email Required")
            Common.alert(alertMessageParameter: "Field cannot be Empty")
            return
        }
    }
    
    @IBAction func didDismissButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}

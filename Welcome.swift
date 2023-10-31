//
//  ViewController.swift
//  FireEvacuation
//
//  Created by FAO on 05/04/23.
//

import UIKit


class Welcome: UIViewController {

    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var getStartedView: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if DefaultWrapper.shared.signedIn == 1 {
            self.navigateToTabbar()
        }
        
        if DefaultWrapper.shared.signedIn == 2 {
            self.navigateToMartial()
        }
        
        if DefaultWrapper.shared.signedIn == 3 {
            self.navigateToTabbar()
        }
        
        if DefaultWrapper.shared.signedIn == 4 {
            self.navigateToFireMarshal()
        }
        
        self.getStartedView.layer.cornerRadius = 5
        self.getStartedView.layer.masksToBounds = true
   
    }
    @IBAction func getStartedButtonTapped(sender: UIButton) {
        let stryBrd = UIStoryboard(name: "Main", bundle: nil)
        let newVc = stryBrd.instantiateViewController(withIdentifier: "CreateAccount") as! CreateAccount
        self.navigationController?.pushViewController(newVc, animated: true)
    }
    
    @IBAction func didSigninButtonTapped(_ sender: UIButton) {
        let stryBrd = UIStoryboard(name: "Main", bundle: nil)
        let newVc = stryBrd.instantiateViewController(withIdentifier: "Sign_In") as! Sign_In
        self.navigationController?.pushViewController(newVc, animated: true)
    }
    
    func navigateToMartial() {
        let strybrd = UIStoryboard(name: "Main", bundle: nil)
        let newVc = strybrd.instantiateViewController(withIdentifier: "FireMarshal") as! FireMarshal
        navigationController?.pushViewController(newVc, animated: true)
    }
    
    func navigateToTabbar() {
        let strybrd = UIStoryboard(name: "Main", bundle: nil)
        let newVc = strybrd.instantiateViewController(withIdentifier: "TabBar") as! TabBar
        navigationController?.pushViewController(newVc, animated: true)
    }
    
    func navigateToFireMarshal() {
        let strybrd = UIStoryboard(name: "Main", bundle: nil)
        let newVc = strybrd.instantiateViewController(withIdentifier: "FireMarshal") as! FireMarshal
        navigationController?.pushViewController(newVc, animated: true)
    }
}

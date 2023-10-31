//
//  Common.swift
//  FireEvacuation
//
//  Created by Amritha on 10/04/23.
//

import Foundation
import UIKit

class Common {
    
    static func alertLogin(alertMessageParameter: String, onClickOfOk: (() -> Void)? = nil) {
        let storyBoard = UIStoryboard(name: "AlertStoryboard", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "AlertViewController")as! AlertViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.alertMessage = alertMessageParameter
        vc.onClickOfOk = onClickOfOk
//        vc.alertImage.image = alertImageParameter
//        vc.alertTitle = alertTitleParameter
        
        
        
        
        // MARK: - To avoid the deprecated key window
        if #available(iOS 13.0, *) {
            let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first
            
            keyWindow?.rootViewController?.present(vc, animated: true)
        }else{
            UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true)
            
        }
    }
    
    static func alert(alertMessageParameter: String) {
        let storyBoard = UIStoryboard(name:"Alerted", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier:"AlertedViewController")as! AlertedViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.alertMessage = alertMessageParameter
//        vc.alertImage.image = alertImageParameter
        
        

        // MARK: - To avoid the deprecated key window
        if #available(iOS 13.0, *) {
            let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first
            
            keyWindow?.rootViewController?.present(vc, animated: true)
        }else{
            UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true)
            
        }
    }
    
    static func EvacuationAlerted(alertMessageParameter: String) {
        let storyBoard = UIStoryboard(name: "EvacuationAlert", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "EvacuationAlertViewController")as! EvacuationAlertViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.alertMessage = alertMessageParameter



        // MARK: - To avoid the deprecated key window
        if #available(iOS 13.0, *) {
            let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first

            keyWindow?.rootViewController?.present(vc, animated: true)
        }else{
            UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true)

        }

    }

    
    
}


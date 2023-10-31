//
//  API Methods.swift
//  FireEvacuation
//
//  Created by Amritha on 10/04/23.
//

import Foundation



class API_Manager: NSObject{
    
    
    
    let Header = "http://gama.mobatia.in:8080/nais-dubai-fire-evacuation/public/api/"
    
    
    
    let register           = "v1/auth/register"
    let login              = "v1/auth/login"
    let forgotpassword     = "v1/auth/forgot-password"
    let logout             = "v1/auth/logout"
    let changepassword     = "v1/auth/change-password"
    let sessionin          = "v1/staffs/mark-attendance"
    let timetable          = "v1/staffs/get-timetable"
    let assemblypoints     = "v1/students/get-assembly-points"
    let yeargroups         = "v1/students/get-yeargroups"
    let devicedata         = "v1/staffs/device-data"
    let sessionout         = "v1/staffs/session-out"
    let getclasssubjects   = "v1/students/get-class-subjects"
    let getclassstudents   = "v1/students/get-class-students"
    let evacuationstart    = "v1/firebase/evacuation-start"
    let evacuationend      = "v1/firebase/evacuation-close"
    let evacuationstatus   = "v1/firebase/evacuation-status"
    let sendstaffnotification = "v1/firebase/send-staff-notification"
    
    
    
    
}



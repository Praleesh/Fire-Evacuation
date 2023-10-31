//
//  DefaultWrapper.swift
//  FireEvacuation
//
//  Created by Amritha on 18/04/23.
//

import Foundation

class DefaultWrapper {
    
    static let shared = DefaultWrapper()
    
    let Defaults = UserDefaults.standard
    
    var tokengenerated: String{
        set {
            Defaults.set(newValue, forKey: DefaultConstants.token)
        }
        get{
            Defaults.string(forKey: DefaultConstants.token)  ?? ""
        }
    }
    
    var staffid: Int {
        set {
            Defaults.set(newValue, forKey: DefaultConstants.staffId)
        }
        get{
            Defaults.integer(forKey: DefaultConstants.staffId)
        }
    }
    
    var staffName: String{
        set {
            Defaults.set(newValue, forKey: DefaultConstants.staffName)
        }
        get{
            Defaults.string(forKey: DefaultConstants.staffName) ?? ""
        }
    }
    
    var subject: String{
        set{
            Defaults.set(newValue, forKey: DefaultConstants.subjectSelected)
        }
        get{
            Defaults.string(forKey: DefaultConstants.subjectSelected)   ??  ""
        }
    }
    
    var session: String{
        set{
            Defaults.set(newValue, forKey: DefaultConstants.sessionSelected)
        }
        get{
            Defaults.string(forKey: DefaultConstants.sessionSelected)   ??  ""
        }
    }
    
    var classid: String{
        set {
            Defaults.set(newValue, forKey: DefaultConstants.classid)
        }
        get {
            Defaults.string(forKey: DefaultConstants.classid) ?? ""
        }
    }
    
    var classname: String{
        set{
            Defaults.set(newValue, forKey: DefaultConstants.classname)
        }
        get {
            Defaults.string(forKey: DefaultConstants.classname) ?? ""
        }
    }
    
    var evacuationid: String{
        set{
            Defaults.set(newValue, forKey: DefaultConstants.evacuationId)
        }
        get{
            Defaults.string(forKey: DefaultConstants.evacuationId) ?? ""
        }
    }
    
    var date: String{
        set{
            Defaults.set(newValue, forKey: DefaultConstants.date)
        }
        get{
            Defaults.string(forKey: DefaultConstants.date) ?? ""
        }
    }
    
    var assemblypoint: String {
        set {
            Defaults.set(newValue, forKey: DefaultConstants.assemblypoint)
        }
        get
        {
            Defaults.string(forKey: DefaultConstants.assemblypoint) ?? ""
        }
    }
    
    var totalstudents: Int {
        set {
            Defaults.set(newValue, forKey: DefaultConstants.totalStudents)
        }
        get {
            Defaults.integer(forKey: DefaultConstants.totalStudents)
        }
    }
    
    var studentsEvacuated: Int {
        set {
            Defaults.set(newValue, forKey: DefaultConstants.studentsEvacuated)
        }
        get
        {
            Defaults.integer(forKey: DefaultConstants.studentsEvacuated)
        }
    }
    
    var signedIn: Int {
        set {
            Defaults.set(newValue, forKey: DefaultConstants.signedIn)
        }
        get {
            Defaults.integer(forKey: DefaultConstants.signedIn)
        }
    }
     
    var evacuatedStatus: Int {
        set {
            Defaults.set(newValue, forKey: DefaultConstants.evacuatedStatus)
        }
        get {
            Defaults.integer(forKey: DefaultConstants.evacuatedStatus)
        }
    }
}

class DefaultConstants {
    static let token            =   "token"
    static let staffId          =   "staffid"
    static let staffName        =   "staffname"
    static let subjectSelected  =   "subject"
    static let sessionSelected  =   "session"
    static let classid          =   "classid"
    static let classname        =   "classname"
    static let evacuationId     =   "evacuationid"
    static let date             =   "date"
    static let assemblypoint    =   "assemblypoint"
    static let totalStudents    =   "totalstudents"
    static let studentsEvacuated =  "studentsEvacuated"
    static let signedIn         =   "signedIn"
    static let evacuatedStatus  =   "evacuatedStatus"
    
}

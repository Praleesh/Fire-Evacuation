//
//  EvacuationEndModel.swift
//  FireEvacuation
//
//  Created by FAO on 14/05/23.
//

import Foundation

class EvacuationEndModel {
    
    var success: Int?
    var message: String?
    var status: Int?
    init(fromdata: [String: Any]) {
        self.success = fromdata["success"] as? Int
        self.message = fromdata["message"] as? String
        self.status = fromdata["status"] as? Int
    }
}

//
//  EvacuationStatusModel.swift
//  FireEvacuation
//
//  Created by FAO on 09/05/23.
//

import Foundation

class EvacuationStatusModel {
    
    var created_by: String?
    var evacuate_end: String?
    var evacuate_id: String?
    var evacuate_start: String?
    var evacuate_type: String?
    var id: Int?
    var status: Int?
    var status_value: String?
    
    init(fromdata: [String: Any]) {
        self.created_by = fromdata["created_by"] as? String
        self.evacuate_end = fromdata["evacuate_end"] as? String
        self.evacuate_id = fromdata["evacuate_id"] as? String
        self.evacuate_start = fromdata["evacuate_start"] as? String
        self.evacuate_type = fromdata["evacuate_type"] as? String
        self.id = fromdata["id"] as? Int
        self.status = fromdata["status"] as? Int
        self.status_value = fromdata["status_value"] as? String
    }
}

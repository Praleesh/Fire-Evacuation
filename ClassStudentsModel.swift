//
//  ClassStudents_Model.swift
//  FireEvacuation
//
//  Created by FAO on 09/05/23.
//

import Foundation

class ClassStudentsModel {
    
    var id: Int?
    var full_name: String?
    var profile_photo_path: String?
    var profile_photo_url: String?
    
    init(fromdata: [String: Any]) {
        self.id = fromdata["id"] as? Int
        self.full_name = fromdata["full_name"] as? String
        self.profile_photo_path = fromdata["profile_photo_path"] as? String
        self.profile_photo_url = fromdata["profile_photo_url"] as? String
    }
}

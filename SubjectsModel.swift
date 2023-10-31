//
//  subject_model.swift
//  FireEvacuation
//
//  Created by Amritha on 03/05/23.
//

import Foundation

class SubjectsModel {
    let class_id: String?
    let name: String?
    init(fromData: [String: Any]) {
        self.class_id = fromData["class_id"]as? String
        self.name = fromData["name"]as? String
    }
}

//
//  session_model.swift
//  FireEvacuation
//
//  Created by Amritha on 02/05/23.
//

import Foundation

class YearGroupModel {
    let id: Int?
    let year_group: String?
    init(fromData: [String: Any]) {
        self.id = fromData["id"]as? Int
        self.year_group = fromData["year_group"]as? String
    }
}

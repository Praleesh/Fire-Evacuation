//
//  CurrentClassModel.swift
//  FireEvacuation
//
//  Created by FAO on 16/05/23.
//

import Foundation

class ClassCurrentModel {
    var evacuated: Int?
    var student_class_section: String?
    var student_id: Int?
    var student_name: String?
    
    init(student_name: String, student_id: Int, student_class_section: String, evacuated: Int) {
           self.student_name = student_name
           self.student_id = student_id
           self.student_class_section = student_class_section
           self.evacuated = evacuated
       }
}

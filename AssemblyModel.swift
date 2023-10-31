//
//  AssemblyModel.swift
//  FireEvacuation
//
//  Created by FAO on 09/05/23.
//

import Foundation

class AssemblyModel {
    var id: Int
    var assemblyPoint: String
    var classes: [String]
    
    init(id: Int, assemblyPoint: String, classes: [String]) {
        self.id = id
        self.assemblyPoint = assemblyPoint
        self.classes = classes
    }
}

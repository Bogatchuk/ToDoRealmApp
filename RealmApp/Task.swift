//
//  Task.swift
//  RealmApp
//
//  Created by Roma Bogatchuk on 27.11.2022.
//

import Foundation
import RealmSwift

class Task: Object {
    
    @Persisted var name = ""
    @Persisted var note = ""
    @Persisted var date = Date()
    @Persisted var isComplited = false
    
    convenience init(name: String, note: String? = "") {
        self.init()
        self.name = name
        self.note = note!
    }
}



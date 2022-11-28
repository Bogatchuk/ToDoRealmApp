//
//  TasksList.swift
//  RealmApp
//
//  Created by Roma Bogatchuk on 27.11.2022.
//

import RealmSwift

class TasksList: Object {
    @Persisted var name = ""
    @Persisted var date = Date()
    @Persisted var tasks = List<Task>()
}

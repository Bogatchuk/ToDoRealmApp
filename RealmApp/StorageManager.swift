//
//  StorageManager.swift
//  RealmApp
//
//  Created by Roma Bogatchuk on 27.11.2022.
//

import Foundation
import RealmSwift

let realm = try! Realm()

class StorageManager{
    private init(){}
    static let shared = StorageManager()
    //MARK: - Tasks Lists  Metods 
    func saveTasksList(_ newList: TasksList){
        try! realm.write{
            realm.add(newList)
        }
    }
    
    func update(_ list: TasksList, newName: String){
        try! realm.write({
            list.name = newName
        })
    }
    
    func delete(_ list: TasksList){
        try! realm.write{
            let tasks = list.tasks
            realm.delete(list.tasks)
            realm.delete(list)
        }
    }
    
    func makeAllDone(_ tasksList: TasksList) {
        try! realm.write {
            tasksList.tasks.setValue(true, forKey: "isComplited")
        }
    }
    
    //MARK: - Tasks Metods
    func saveTask(_ newTask: Task, for list: TasksList){
        try! realm.write{
            list.tasks.append(newTask)
            
        }
    }
    
    func updateTask(_ task: Task, newName: String, newNote: String){
        try! realm.write({
            task.name = newName
            task.note = newNote
            
        })
    }
    
    func deleteTask(_ task: Task){
        try! realm.write{
            realm.delete(task)
        }
    }
    
    func makeDone(_ task: Task){
        try! realm.write({
            task.isComplited.toggle()
        })
        
    }
    
}

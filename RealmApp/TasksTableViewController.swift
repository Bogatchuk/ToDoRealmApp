//
//  TasksTableViewController.swift
//  RealmApp
//
//  Created by Roma Bogatchuk on 27.11.2022.
//

import UIKit
import RealmSwift

class TasksTableViewController: UITableViewController {
    
    var currentList: TasksList!
    private var currentTasks: Results<Task>!
    private var completedTasks: Results<Task>!
    
    private var isEditingMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = currentList.name
        filtringTask()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return section == 0 ? currentTasks.count : completedTasks.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellTask", for: indexPath)

        var config = cell.defaultContentConfiguration()
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        config.text = task.name
        config.secondaryText = task.note
        cell.contentConfiguration = config
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        var task: Task!
        
        task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]

        let delete = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.shared.deleteTask(task)
            self.filtringTask()
        }


        let update = UIContextualAction(style: .normal, title: "Update") { _, _, _ in
            self.alertForAddNewTaskAndUpdate(task: task)
            self.filtringTask()
        }
        update.backgroundColor = .darkGray
        let done = UIContextualAction(style: .normal, title: "Done") { _, _, _ in
            StorageManager.shared.makeDone(task)
            self.filtringTask()
        }
        done.backgroundColor = .darkText

        let swipeAction = UISwipeActionsConfiguration(actions: [delete, update, done])
        return swipeAction
    }
    
  

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        } else if editingStyle == .none {
            
        }
    }
    


  
    
    @IBAction func addNewTaskPressed(_ sender: UIBarButtonItem) {
        alertForAddNewTaskAndUpdate()
    }
    
    @IBAction func editTaskPressed(_ sender: UIBarButtonItem) {
        isEditingMode.toggle()
        tableView.setEditing(isEditingMode, animated: true)
    }
    
    func filtringTask(){
        currentTasks = currentList.tasks.filter("isComplited = false")
        completedTasks = currentList.tasks.filter("isComplited = true")
        tableView.reloadData()
    }

}

extension TasksTableViewController{
    
    func alertForAddNewTaskAndUpdate(task: Task? = nil){
        
        var title = "New task"
        var done = "Done"
        
        if task != nil {
            title = "Edit task"
            done = "Update"
        }
        
        let alert = UIAlertController(title: title, message: "Please insert task value", preferredStyle: .alert)
        var nameTextField = UITextField()
        var noteTextField = UITextField()
        
        let doneAction = UIAlertAction(title: done, style: .default){ _ in
            guard let newTask = nameTextField.text, !newTask.isEmpty else { return }
            if let task = task {
                if let newNote = noteTextField.text, !newNote.isEmpty{
                    StorageManager.shared.updateTask(task, newName: newTask, newNote: newNote)
                }else{
                    StorageManager.shared.updateTask(task, newName: newTask, newNote: "")
                }
                self.filtringTask()
            } else {
                let task = Task()
                task.name = newTask
                if let note  = noteTextField.text, !note.isEmpty {
                    task.note = note
                }
                StorageManager.shared.saveTask(task, for: self.currentList)
                self.filtringTask()
                
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        
        alert.addAction(doneAction)
        alert.addAction(cancelAction)
        alert.addTextField(){ textField in
            nameTextField = textField
            nameTextField.placeholder = "Name task"
        }
        
        alert.addTextField(){ textField in
            noteTextField = textField
            noteTextField.placeholder = "Note task"
            
        }
        
        present(alert, animated: true)
    }
}

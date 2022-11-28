//
//  TasksListTableViewController.swift
//  RealmApp
//
//  Created by Roma Bogatchuk on 27.11.2022.
//

import UIKit
import RealmSwift

class TasksListTableViewController: UITableViewController {
    var tasksLists: Results<TasksList>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tasksLists = realm.objects(TasksList.self)
        navigationItem.leftBarButtonItem = editButtonItem
     
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasksLists.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        var config = cell.defaultContentConfiguration()
        config.text = tasksLists[indexPath.row].name
        config.secondaryText = String(tasksLists[indexPath.row].tasks.filter("isComplited = false").count)
        cell.contentConfiguration = config
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let currentList = tasksLists[indexPath.row]
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.shared.delete(currentList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        
        let update = UIContextualAction(style: .normal, title: "Update") { _, _, _ in
            self.alertForAddAndUpdateList(list: currentList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            
        }
        update.backgroundColor = .darkGray
        let done = UIContextualAction(style: .normal, title: "Done") { _, _, _ in
            StorageManager.shared.makeAllDone(currentList)
            tableView.reloadData()
        }
        done.backgroundColor = .darkText
        
        let swipeAction = UISwipeActionsConfiguration(actions: [delete, update, done])
        return swipeAction
    }
    
 

    @IBAction func addNewListButtonPressed(_ sender: UIBarButtonItem) {
        alertForAddAndUpdateList()
    }
    

    @IBAction func sortedSegmentedPressed(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            tasksLists = tasksLists.sorted(byKeyPath: "name")
        }else{
            tasksLists = tasksLists.sorted(byKeyPath: "date")
        }
        tableView.reloadData()
    }
    

    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow{
            let taskList = tasksLists[indexPath.row]
            let tasksVC = segue.destination as! TasksTableViewController
            tasksVC.currentList = taskList
        }

    }
  

}

extension TasksListTableViewController {
    func alertForAddAndUpdateList(list: TasksList? = nil, complited: (()->())? = nil ){
        
        var title = "Add new Tasks List"
        var  done = "Save"
        
        if list != nil{
            title = "Update list"
            done = "Update"
        }
        
        let alert = UIAlertController(title: title, message: "Pleas imput name list", preferredStyle: .alert)
        var alertTextField: UITextField!
        let saveAction = UIAlertAction(title: done, style: .default){ _ in
            
            guard let listName = alertTextField.text, !listName.isEmpty else {return}
            
            if let list = list {
                StorageManager.shared.update(list, newName: listName)
                if complited != nil { complited!() }
            }else{
                let newList = TasksList()
                newList.name = listName
                StorageManager.shared.saveTasksList(newList)
                self.tableView.insertRows(at: [IndexPath(row: self.tasksLists.count - 1, section: 0)], with: .automatic)
                
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        alert.addTextField{ textField in
            alertTextField = textField
            alertTextField.placeholder = "List Name"
            
        }
        
        present(alert, animated: true)
        
    }
    
    
}

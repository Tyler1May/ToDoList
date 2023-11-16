//
//  ListsViewController.swift
//  ToDoist
//
//  Created by Tyler May on 11/14/23.
//

import UIKit
import CoreData

class ListsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ItemsViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var toDoLists: [ToDoList] = []
    
    private let itemManager = ItemManager.shared

        override func viewDidLoad() {
            super.viewDidLoad()
            itemManager.fetchAllToDoLists()
            toDoLists = itemManager.allItems
            tableView.reloadData()
            tableView.dataSource = self
            tableView.delegate = self
        }

    func receiveItems(_: ItemsViewController, items: [Item], indexPath: IndexPath) {
        let selectedToDoList = toDoLists[indexPath.row]
        selectedToDoList.items = NSSet(array: items)
        tableView.reloadData()
    }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return toDoLists.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoListCell", for: indexPath)
            let toDoList = toDoLists[indexPath.row]
            cell.textLabel?.text = toDoList.title
            cell.detailTextLabel?.text = "\(toDoList.itemsArray.count) items"
            return cell
        }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        itemManager.deleteToDoList(toDoLists[indexPath.row])
        toDoLists.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
    }



    

        @IBAction func addListButtonTapped(_ sender: UIBarButtonItem) {
            let alertController = UIAlertController(title: "New List", message: nil, preferredStyle: .alert)

            alertController.addTextField { textField in
                textField.placeholder = "Enter list title"
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

            let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
                guard let textField = alertController.textFields?.first,
                      let title = textField.text else { return }
                self?.createToDoList(title: title)
            }

            alertController.addAction(cancelAction)
            alertController.addAction(saveAction)

            present(alertController, animated: true, completion: nil)
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toItems", sender: tableView.cellForRow(at: indexPath))
    }
    
    func createToDoList(title: String) {
        let newToDoList = ToDoList(context: PersistenceController.shared.viewContext)
        newToDoList.id = UUID().uuidString
        newToDoList.title = title
        newToDoList.createdAt = Date()
        newToDoList.modifiedAt = Date()
        toDoLists.insert(newToDoList, at: 0)
        tableView.reloadData()
        PersistenceController.shared.saveContext()
    }
    
    @IBSegueAction func toItems(_ coder: NSCoder, sender: Any?) -> ItemsViewController? {
        if let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell),
           let itemsViewController = ItemsViewController(coder: coder, with: toDoLists[indexPath.row]) {
            itemsViewController.delegate = self
            itemsViewController.indexPath = indexPath
            return itemsViewController
        }
        return nil
    }
    
}

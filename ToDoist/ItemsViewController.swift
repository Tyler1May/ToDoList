//
//  ViewController.swift
//  ToDoist
//
//  Created by Parker Rushton on 10/15/22.
//

import UIKit

protocol ItemsViewControllerDelegate {
    func receiveItems(_:ItemsViewController, items: [Item], indexPath: IndexPath)
}

class ItemsViewController: UIViewController {
    
    var selectedToDoList: ToDoList?
    var delegate: ItemsViewControllerDelegate?
    var indexPath: IndexPath?
    
    init?(coder: NSCoder, with toDoList: ToDoList) {
        super.init(coder: coder)
        selectedToDoList = toDoList
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum TableSection: Int, CaseIterable {
        case incomplete, complete
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    
    // MARK: - Properties
    
    private let itemManager = ItemManager.shared

    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        
    }

}


// MARK: - Private

private extension ItemsViewController {

    func item(at indexPath: IndexPath) -> Item {
        let tableSection = TableSection(rawValue: indexPath.section)!
        switch tableSection {
        case .incomplete:
            return (selectedToDoList?.itemsArray[indexPath.row])!
        case .complete:
            return (selectedToDoList?.itemsArray[indexPath.row])!
        }
    }

}



// MARK: - TableView DataSource

extension ItemsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let tableSection = TableSection(rawValue: section)!
        let items = selectedToDoList?.itemsArray
        switch tableSection {
        case .incomplete:
            return "To-Do (\(items?.filter { $0.isCompleted == false }.count ?? 0))"
        case .complete:
            return "Completed (\(items?.filter { $0.isCompleted }.count ?? 0))"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        TableSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tableSection = TableSection(rawValue: section)!
        switch tableSection {
        case .incomplete:
            return selectedToDoList?.itemsArray.filter { !$0.isCompleted }.count ?? 0
        case .complete:
            return selectedToDoList?.itemsArray.filter { $0.isCompleted }.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemTableViewCell.reuseIdentifier) as! ItemTableViewCell
        guard let itemsArray = selectedToDoList?.itemsArray else {
            return cell
        }
        
        let tableSection = TableSection(rawValue: indexPath.section)!
        let items = (tableSection == .incomplete) ? itemsArray.filter { !$0.isCompleted } : itemsArray.filter { $0.isCompleted }
        let item = items[indexPath.row]
        cell.update(with: item)
        
        return cell
    }

    
    // Swipe to Delete
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        guard let selectedToDoList = selectedToDoList else {
            return
        }
        itemManager.delete(at: indexPath, from: selectedToDoList)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.reloadData()
        delegate?.receiveItems(self, items: selectedToDoList.itemsArray, indexPath: indexPath)
    }
    
}

// MARK: - TableView Delegate

extension ItemsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = item(at: indexPath)
        itemManager.toggleItemCompletion(item, in: selectedToDoList!)
        
        tableView.reloadData()
    }
    
}


// MARK: - TextField Delegate

extension ItemsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty, let selectedToDoList = selectedToDoList, let indexPath = indexPath else {
            return true
        }

        itemManager.createNewItem(with: text, for: selectedToDoList)
        delegate?.receiveItems(self, items: selectedToDoList.itemsArray, indexPath: indexPath)

        tableView.reloadSections([TableSection.incomplete.rawValue], with: .automatic)
        textField.text = ""
        return true
    }

    
}

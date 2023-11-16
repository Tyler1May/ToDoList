//
//  ItemManager.swift
//  ToDoist
//
//  Created by Parker Rushton on 10/21/22.
//

import Foundation
import CoreData

class ItemManager {
    static let shared = ItemManager()
        
    var allItems = [ToDoList]()
    var incompleteItems = [Item]()
    var completedItems = [Item]()
    
    
    // MARK: - Item CRUD
    
    // Create
        
    func createNewItem(with title: String, for toDoList: ToDoList) {
        let newItem = Item(context: PersistenceController.shared.viewContext)
        newItem.id = UUID().uuidString
        newItem.title = title
        newItem.createdAt = Date()
        newItem.completedAt = nil
        newItem.toDoList = toDoList
        toDoList.addToItems(newItem)
        PersistenceController.shared.saveContext()
    }
    
    // Retrieve
    
//    func fetchIncompleteItems() {
//        let fetchRequest = Item.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "completedAt == nil")
//        let context = PersistenceController.shared.viewContext
//        let fetchedItems = try? context.fetch(fetchRequest)
//        self.incompleteItems = fetchedItems ?? []
//    }
//
//    func fetchCompletedItems() {
//        let fetchRequest = Item.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "completedAt != nil")
//        let context = PersistenceController.shared.viewContext
//        let fetchedItems = try? context.fetch(fetchRequest)
//        self.completedItems = fetchedItems ?? []
//    }
    
    // Update
    
    func toggleItemCompletion(_ item: Item, in toDoList: ToDoList) {
        item.completedAt = item.isCompleted ? nil : Date()
        PersistenceController.shared.saveContext()
    }
    
    // Delete
    
    func delete(at indexPath: IndexPath, from toDoList: ToDoList) {
        let itemToDelete = item(at: indexPath, from: toDoList)

            remove(itemToDelete)

//        PersistenceController.shared.saveContext()
    }


    func remove(_ item: Item) {
        
        let context = PersistenceController.shared.viewContext
        context.delete(item)
        PersistenceController.shared.saveContext()
    }
    
    private func item(at indexPath: IndexPath, from toDoList: ToDoList) -> Item {
        var itemsArray = toDoList.itemsArray
        if indexPath.section == 0 {
            itemsArray = toDoList.itemsArray.filter { $0.isCompleted == false }
        } else {
            itemsArray = toDoList.itemsArray.filter { $0.isCompleted }
        }
        return itemsArray[indexPath.row]
    }
    
    // MARK: - ToDoList CRUD
    
    // Create
    
    func createNewToDoList(with title: String) {
        let newToDoList = ToDoList(context: PersistenceController.shared.viewContext)
        newToDoList.id = UUID().uuidString
        newToDoList.title = title
        newToDoList.createdAt = Date()
        newToDoList.modifiedAt = Date()
        PersistenceController.shared.saveContext()
    }

    // Retrieve
    
    func fetchAllToDoLists() {
        let fetchRequest: NSFetchRequest<ToDoList> = ToDoList.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "modifiedAt", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let context = PersistenceController.shared.viewContext
        let fetchedToDoLists = try? context.fetch(fetchRequest)
        self.allItems = fetchedToDoLists ?? []
    }
    // Update
    
    func updateToDoList(_ toDoList: ToDoList, with title: String) {
        toDoList.title = title
        toDoList.modifiedAt = Date()
        PersistenceController.shared.saveContext()
    }
    // Delete
    
    func deleteToDoList(_ toDoList: ToDoList) {
        let context = PersistenceController.shared.viewContext
        context.delete(toDoList)
        PersistenceController.shared.saveContext()
    }
    
}

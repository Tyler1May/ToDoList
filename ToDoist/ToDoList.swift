//
//  ToDoList.swift
//  ToDoist
//
//  Created by Tyler May on 11/14/23.
//

import Foundation

extension ToDoList {
    var itemsArray: [Item] {
        return items?.allObjects as? [Item] ?? []
    }
}

//
//  Board.swift
//  ToDoList
//
//  Created by Jacob Sanchez on 12/21/14.
//  Copyright (c) 2014 JSanch. All rights reserved.

import CoreData

class Board
{
    var id:String?
    var cd_object:NSManagedObject?
    
    var items:[Item]
    var name:String
    var selected:Bool
    
    // default constructor
    init()
    {
        items = []
        selected = false
        name = ""
    }
    
    // constructor for retrieval
    init(cd_object:NSManagedObject)
    {
        self.cd_object = cd_object
        id = cd_object.objectID.URIRepresentation().lastPathComponent!
        name = cd_object.valueForKey("name") as String
        selected = cd_object.valueForKey("selected") as String == "selected"
        items = []
    }
    
    // constructor for creation
    init(name:String)
    {
        items = []
        selected = false
        self.name = name
    }
    
    func getNumItems() -> Int
    {
        return items.count
    }
    
    func getNumItemsCompleted() -> Int
    {
        var num_completed = 0
        
        for i in items
        {
            if i.isCompleted()
            {
                num_completed++
            }
        }
        
        return num_completed
    }
    
    func getCompletionPerc() -> Double
    {
        return Double(getNumItemsCompleted()) / Double(getNumItems())
    }
    
    func getCompletionPercString() -> String
    {
        return "\(getNumItemsCompleted())/\(getNumItems())"
    }

    func isEqualTo(comp_board:Board) -> Bool
    {
        var same_name:Bool = comp_board.name == name
        var same_num_items:Bool = comp_board.items.count == items.count
        return same_name && same_num_items
    }
}

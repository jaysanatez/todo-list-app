//
//  ItemDataAccess.swift
//  ToDoList
//
//  Created by Jacob Sanchez on 1/5/15.
//  Copyright (c) 2015 JSanch. All rights reserved.

import UIKit
import CoreData

class ItemDataAccess:NSObject
{
    var context:NSManagedObjectContext
    
    override init()
    {
        var app_del:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        context = app_del.managedObjectContext!
        
        super.init()
    }
    
    // Item CRUD
    
    func fetchItemsForBoard(board_id:String) -> [Item]
    {
        var items:[Item] = []
        var request:NSFetchRequest = NSFetchRequest(entityName:"Items")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format:"board_id = %@", board_id)
        
        var results:NSArray = context.executeFetchRequest(request, error:nil)!
        
        if results.count > 0
        {
            for item_res in results
            {
                var cd_item:NSManagedObject = item_res as NSManagedObject
                var i:Item = Item(cd_object: cd_item)
                items.append(i)
            }
        }
        
        return sortItems(items)
    }
    
    func sortItems(items:[Item]) -> [Item]
    {
        var sorted_items:Array<Item> = items.sorted({
            var i1:Item = $0
            var i2:Item = $1
            return !i1.hasPriorityLessThanItem(i2)
        })
        
        sorted_items = sorted_items.sorted({
            var i1:Item = $0
            var i2:Item = $1
            return i1.hasStatusLessThanItem(i2)
        })
        
        return sorted_items as AnyObject as [Item]
    }
    
    func addItemToBoard(board_id:String, item:Item)
    {
        var new_item:NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName("Items", inManagedObjectContext:context) as NSManagedObject
        
        new_item.setValue(board_id, forKey:"board_id")
        new_item.setValue(item.title, forKey:"title")
        new_item.setValue(item.description, forKey:"descr")
        new_item.setValue(item.is_task ? "Task" : "Event", forKey:"type")
        new_item.setValue(replaceWithUnderscores(item.status.description), forKey:"status")
        new_item.setValue(item.priority.description, forKey:"priority")
        new_item.setValue(item.day.description, forKey:"day")

        context.save(nil)
    }
    
    func updateItem(item:Item)
    {
        var updated_item:NSManagedObject = item.cd_object!
        
        updated_item.setValue(item.board_id, forKey:"board_id")
        updated_item.setValue(item.title, forKey:"title")
        updated_item.setValue(item.description, forKey:"descr")
        updated_item.setValue(item.is_task ? "Task" : "Event", forKey:"type")
        updated_item.setValue(replaceWithUnderscores(item.status.description), forKey:"status")
        updated_item.setValue(item.priority.description, forKey:"priority")
        updated_item.setValue(item.day.description, forKey:"day")
        
        context.save(nil)
    }
    
    func removeItem(item:Item)
    {
        context.deleteObject(item.cd_object!)
        context.save(nil)
    }
    
    func replaceWithUnderscores(s:String) -> String
    {
        return s.stringByReplacingOccurrencesOfString(" ",withString:"_", options:NSStringCompareOptions.LiteralSearch, range:nil)
    }
}

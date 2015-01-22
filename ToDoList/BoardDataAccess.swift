//
//  BoardDataAccess.swift
//  ToDoList
//
//  Created by Jacob Sanchez on 12/21/14.
//  Copyright (c) 2014 JSanch. All rights reserved.

import UIKit
import CoreData

class BoardDataAccess:NSObject
{
    var context:NSManagedObjectContext
    var item_dao:ItemDataAccess
    
    override init()
    {
        item_dao = ItemDataAccess()
        var app_del:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        context = app_del.managedObjectContext!
        
        super.init()
    }
    
    // Board CRUD
    
    func fetchBoards() -> [Board]
    {
        var boards:[Board] = []
        var request:NSFetchRequest = NSFetchRequest(entityName:"Boards")
        request.returnsObjectsAsFaults = false
        
        var results:NSArray = context.executeFetchRequest(request, error:nil)!
        if results.count > 0
        {
            for board_res in results
            {
                var cd_board:NSManagedObject = board_res as NSManagedObject
                var b:Board = Board(cd_object:cd_board)
                b.items = item_dao.fetchItemsForBoard(b.id!) // get items, store them
                boards.append(b)
            }
        }
        
        // sort so selected board ends up on top
        boards = boards.sorted({
            var b1:Board = $0
            var b2:Board = $1
            return b1.selected && !b2.selected
        })
        
        return boards
    }
    
    func addBoard(board:Board)
    {
        var new_board:NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName("Boards", inManagedObjectContext:context) as NSManagedObject
        
        new_board.setValue(board.name, forKey:"name")
        new_board.setValue(board.selected ? "selected" : "unselected", forKey:"selected")
        
        context.save(nil)
    }
    
    func updateBoard(board:Board)
    {
        var updated_board:NSManagedObject = board.cd_object!
        updated_board.setValue(board.name, forKey:"name")
        updated_board.setValue(board.selected ? "selected" : "unselected", forKey:"selected")
        
        context.save(nil)
    }
    
    func updateAllBoards(boards:[Board])
    {
        for board in boards
        {
            var updated_board:NSManagedObject = board.cd_object!
            updated_board.setValue(board.name, forKey:"name")
            updated_board.setValue(board.selected ? "selected" : "unselected", forKey:"selected")
        }
        
        context.save(nil)
    }
    
    func removeBoard(board:Board)
    {
        context.deleteObject(board.cd_object!)
        context.save(nil)
        
        for i in board.items
        {
            item_dao.removeItem(i as Item)
        }
    }
}
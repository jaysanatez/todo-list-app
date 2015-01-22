//
//  BoardDetailView.swift
//  ToDoList
//
//  Created by Jacob Sanchez on 1/4/15.
//  Copyright (c) 2015 JSanch. All rights reserved.

import UIKit

class BoardDetailView: UIView
{
    @IBOutlet var view:UIView!
    @IBOutlet var name_field:UITextField!
    
    var board:Board
 
    required init(coder aDecoder: NSCoder)
    {
        board = Board()
        
        super.init(coder:aDecoder)
        NSBundle.mainBundle().loadNibNamed("BoardDetailView",owner:self,options:nil)
        self.addSubview(self.view)
    }
    
    func displayDefaultBoard()
    {
        name_field.placeholder = "Board Title"
    }
    
    func displayBoard(board:Board)
    {
        name_field.text = board.name
    }
    
    func getUpdatedBoard() -> Board
    {
        board.name = name_field.text
        return board
    }
}

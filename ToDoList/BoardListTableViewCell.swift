//
//  BoardListTableViewCell.swift
//  ToDoList
//
//  Created by Jacob Sanchez on 12/22/14.
//  Copyright (c) 2014 JSanch. All rights reserved.

import UIKit

class BoardListTableViewCell: UITableViewCell
{
    @IBOutlet var name_label:UILabel!
    @IBOutlet var progress_fraction:UILabel!
    @IBOutlet var item_progress:UIProgressView!
    var board:Board

    required init(coder aDecoder:NSCoder)
    {
        board = Board()
        super.init(coder:aDecoder)
    }
    
    func loadDisplay()
    {
        name_label.text = board.name
        progress_fraction.text = board.getCompletionPercString()
        
        if board.getNumItems() > 0
        {
            item_progress.progress = Float(board.getCompletionPerc())
        }
        else
        {
            item_progress.progress = 0.0
        }
        
        if board.selected
        {
            setSelected()
        }
        else
        {
            setUnselected()
        }
    }
    
    func setSelected()
    {
        contentView.backgroundColor = UIColor.redColor()
    }
    
    func setUnselected()
    {
        contentView.backgroundColor = UIColor.whiteColor()
    }
}

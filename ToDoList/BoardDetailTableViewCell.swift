//
//  BoardDetailTableViewCell.swift
//  ToDoList
//
//  Created by Jacob Sanchez on 1/7/15.
//  Copyright (c) 2015 JSanch. All rights reserved.
//

import UIKit

class BoardDetailTableViewCell: UITableViewCell
{
    @IBOutlet var text_label:UILabel!
    @IBOutlet var selector_bar:UIView!
    var board:Board
    
    required init(coder aDecoder:NSCoder)
    {
        board = Board()
        super.init(coder:aDecoder)
    }
    
    func loadDisplay()
    {
        text_label.text = board.name
    }
    
    func isSelected() -> Bool
    {
        return text_label.textColor == UIColor(red:1.0, green:0.0, blue:0.0, alpha:0.9)
    }
    
    func setSelected()
    {
        var my_red:UIColor = UIColor(red:1.0, green:0.0, blue:0.0, alpha:0.9)
        text_label.textColor = my_red
        selector_bar.backgroundColor = my_red
    }
    
    func setUnselected()
    {
        text_label.textColor = UIColor.whiteColor()
        selector_bar.backgroundColor = UIColor.clearColor()
    }
    
}

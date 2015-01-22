//
//  BoardsDetailView.swift
//  ToDoList
//
//  Created by Jacob Sanchez on 1/7/15.
//  Copyright (c) 2015 JSanch. All rights reserved.

import UIKit

class BoardsDetailView: UIView, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet var view:UIView!
    @IBOutlet var tableView:UITableView!
    @IBOutlet var text_label:UILabel!
    var selected_board:Board?
    var boards:[Board]
    
    required init(coder aDecoder: NSCoder)
    {
        boards = []
        super.init(coder:aDecoder)
        NSBundle.mainBundle().loadNibNamed("BoardsDetailView",owner:self,options:nil)
        self.addSubview(self.view)
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        tableView.registerNib(UINib(nibName:"BoardDetailTableViewCell", bundle:NSBundle.mainBundle()), forCellReuseIdentifier:"BoardCell")
    }
    
    func initializeLabel(message:String)
    {
        text_label.text = message
    }
    
    func reloadBoards(boards:[Board], selected_board:Board?)
    {
        self.boards = boards
        self.selected_board = selected_board
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return boards.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:BoardDetailTableViewCell = tableView.dequeueReusableCellWithIdentifier("BoardCell") as BoardDetailTableViewCell
        
        
        cell.board = boards[indexPath.row]
        cell.loadDisplay()
        
        if selected_board != nil && selected_board!.isEqualTo(cell.board)
        {
            cell.setSelected()
            tableView.selectRowAtIndexPath(indexPath, animated:false, scrollPosition: UITableViewScrollPosition.None)
        }
        else
        {
            cell.setUnselected()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        var cell:BoardDetailTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as BoardDetailTableViewCell
        
        if cell.isSelected()
        {
            selected_board = nil
            cell.setUnselected()
        }
        else
        {
            selected_board = cell.board
            cell.setSelected()
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
    {
        var cell:BoardDetailTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as BoardDetailTableViewCell
        cell.setUnselected()
    }
    
    func getSelectedBoard() -> Board?
    {
        return selected_board
    }
}

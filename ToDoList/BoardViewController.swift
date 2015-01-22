//
//  BoardViewController.swift
//  ToDoList
//
//  Created by Jacob Sanchez on 12/22/14.
//  Copyright (c) 2014 JSanch. All rights reserved.

import UIKit

class BoardViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,SwipeCellDelegate
{
    // settings pane
    @IBOutlet var add_item_button:UIButton!
    @IBOutlet var edit_board_button:UIButton!
    @IBOutlet var delete_board_button:UIButton!
    @IBOutlet var save_item_button:UIButton!
    @IBOutlet var cancel_button:UIButton!
    @IBOutlet var save_board_button:UIButton!
    @IBOutlet var settings_pane_top:NSLayoutConstraint!
    
    // add item pane
    @IBOutlet var additem_view:ItemDetailView!
    @IBOutlet var additem_view_spacefrombottom:NSLayoutConstraint!
    @IBOutlet var additem_view_height:NSLayoutConstraint!
    
    // edit board pane
    @IBOutlet var editboard_view:BoardDetailView!
    @IBOutlet var editboard_view_spacefromtop:NSLayoutConstraint!
    
    @IBOutlet var tableView:UITableView!
    @IBOutlet var tip_view:UIView!
    @IBOutlet var item_progress:UIProgressView!
    
    var board:Board
    var cells_currently_editing:NSMutableSet
    var board_dao:BoardDataAccess
    var item_dao:ItemDataAccess
    
    // button set constants
    let CURRENT_BUTTONS = 0
    let DEFAULT_BUTTONS = 1
    let CREATE_ITEM_BUTTONS = 2
    let EDIT_BOARD_BUTTONS = 3
    
    init(nibName nibNameOrNil:String!, bundle nibBundleOrNil:NSBundle!, board:Board)
    {
        self.board = board
        board_dao = BoardDataAccess()
        item_dao = ItemDataAccess()
        cells_currently_editing = NSMutableSet()
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }

    required init(coder aDecoder:NSCoder)
    {
        board = Board()
        board_dao = BoardDataAccess()
        item_dao = ItemDataAccess()
        cells_currently_editing = NSMutableSet()
        super.init(coder:aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = board.name
        tip_view.hidden = board.items.count != 0
        cells_currently_editing = NSMutableSet()
        item_progress.progress = Float(board.getCompletionPerc())
        tableView.registerNib(UINib(nibName: "BoardTableViewCell",
            bundle: NSBundle.mainBundle()), forCellReuseIdentifier:"BoardCell")
        
        // settings bar button
        var settings_button:UIBarButtonItem = UIBarButtonItem(image:UIImage(named:"gear"), style:UIBarButtonItemStyle.Plain, target:self, action:"settingsButtonTapped")
        self.navigationItem.rightBarButtonItem = settings_button
        
        // settings pane
        var button_array:[UIButton] = [add_item_button, edit_board_button, delete_board_button, save_item_button, cancel_button, save_board_button]
        for button in button_array
        {
            button.layer.borderColor = UIColor.redColor().CGColor
            button.layer.borderWidth = 2
            button.layer.cornerRadius = 10
            button.clipsToBounds = true
            
            button.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
            button.titleLabel?.textAlignment = NSTextAlignment.Center
            button.titleLabel?.font = UIFont.systemFontOfSize(18)
        }
        
        settings_pane_top.constant = -100
        hackatizeMeCaptain()
        showDefaultButtons()
    }
    
    func hackatizeMeCaptain()
    {
        // close-open-close hack to fix pop layout
        setDefaultEditorConstraints()
        view.layoutIfNeeded()
        
        additem_view_spacefrombottom.constant = 0
        view.layoutIfNeeded()
        
        setDefaultEditorConstraints()
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        if tableView.indexPathForSelectedRow() != nil
        {
            tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow()!, animated:true)
            reloadItems()
        }
        super.viewDidAppear(animated)
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return board.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:BoardTableViewCell = tableView.dequeueReusableCellWithIdentifier("BoardCell") as BoardTableViewCell
        
        if cells_currently_editing.containsObject(indexPath)
        {
            cell.openCell()
        }
        
        cell.delegate = self
        cell.item = board.items[indexPath.row]
        cell.loadDisplay()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var i:Item = board.items[indexPath.row]
        var controller:ItemViewController = ItemViewController(nibName:"ItemViewController", bundle:NSBundle.mainBundle(), item:i, board:board)
        self.navigationController?.pushViewController(controller, animated:true)
    }
    
    func settingsButtonTapped()
    {
        toggleSettingsPane(CURRENT_BUTTONS)
    }
    
    func toggleSettingsPane(button_set:Int)
    {
        settings_pane_top.constant = settings_pane_top.constant == 0 ? -100 : 0
        UIView.animateWithDuration(0.5, animations: {
            self.view.layoutIfNeeded()
        }, completion: {
            (value:Bool) in
            self.displayButtonSet(button_set)
        })
    }
    
    @IBAction func addItem()
    {
        additem_view.displayDefaultItem()
        toggleSettingsPane(CREATE_ITEM_BUTTONS)
        
        self.title = "New Item"
        openItemDetailView()
    }
    
    func setDefaultEditorConstraints()
    {
        // getting editor specs just right ;)
        var height:CGFloat = UIScreen.mainScreen().bounds.height - 64 // 44 from nav bar, 20 from status bar
        additem_view_height.constant = height
        additem_view_spacefrombottom.constant = -1 * height
        additem_view.setViewDimensions(height)
    }
    
    @IBAction func editBoardTapped()
    {
        editboard_view.displayBoard(board)
        toggleSettingsPane(EDIT_BOARD_BUTTONS)
        
        self.title = "Edit \(board.name)"
        openBoardDetailView()
    }
    
    @IBAction func deleteBoardTapped()
    {
        var alert:UIAlertView = UIAlertView(title:"WARNING", message:"Once deleted, this board cannot be recovered.", delegate:self, cancelButtonTitle:"Cancel", otherButtonTitles: "Delete Board")
        alert.show()
    }
    
    func alertView(alertView:UIAlertView, didDismissWithButtonIndex buttonIndex:Int)
    {
        if buttonIndex == 1
        {
            board_dao.removeBoard(board)
            self.navigationController?.popViewControllerAnimated(true)
        }
        toggleSettingsPane(CURRENT_BUTTONS)
    }
    
    @IBAction func createItem()
    {
        var new_item:Item = additem_view.getUpdatedItem()
        item_dao.addItemToBoard(board.id!,item:new_item)
        reloadItems()

        toggleSettingsPane(DEFAULT_BUTTONS)
        dismissItemDetailView()
    }
    
    @IBAction func cancelChanges()
    {
        toggleSettingsPane(DEFAULT_BUTTONS)
        dismissItemDetailView()
        dismissBoardDetailView()
    }
    
    @IBAction func saveBoardEdits()
    {
        var updated_board:Board = editboard_view.getUpdatedBoard()
        board_dao.updateBoard(updated_board)
        
        // local update
        board = updated_board
        self.title = board.name
        
        toggleSettingsPane(DEFAULT_BUTTONS)
        dismissBoardDetailView()
    }
    
    func openItemDetailView()
    {
        additem_view_spacefrombottom.constant = 0
        UIView.animateWithDuration(0.5, animations:{
            self.view.layoutIfNeeded()
        })
    }
    
    func dismissItemDetailView()
    {
        self.title = board.name
        additem_view.dismissKeyboards()
        additem_view_spacefrombottom.constant = -1 * (UIScreen.mainScreen().bounds.height - 64)
        UIView.animateWithDuration(0.5, animations:{
            self.view.layoutIfNeeded()
        })
    }
    
    func openBoardDetailView()
    {
        editboard_view_spacefromtop.constant = 0
        UIView.animateWithDuration(0.5, animations:{
            self.view.layoutIfNeeded()
        })
    }
    
    func dismissBoardDetailView()
    {
        self.title = board.name
        editboard_view_spacefromtop.constant = -135
        UIView.animateWithDuration(0.5, animations:{
            self.view.layoutIfNeeded()
        })
    }
    
    func displayButtonSet(button_set:Int)
    {
        switch button_set
        {
            case CURRENT_BUTTONS:
                break
            case DEFAULT_BUTTONS:
                showDefaultButtons()
                break
            case EDIT_BOARD_BUTTONS:
                showBoardEditButtons()
                break
            case CREATE_ITEM_BUTTONS:
                showAddItemButtons()
                break
            default:
                break
        }
    }
    
    func showDefaultButtons()
    {
        add_item_button.hidden = false
        edit_board_button.hidden = false
        delete_board_button.hidden = false
        
        save_item_button.hidden = true
        save_board_button.hidden = true
        cancel_button.hidden = true
    }
    
    func showAddItemButtons()
    {
        add_item_button.hidden = true
        edit_board_button.hidden = true
        delete_board_button.hidden = true
        
        save_item_button.hidden = false
        save_board_button.hidden = true
        cancel_button.hidden = false
    }
    
    func showBoardEditButtons()
    {
        add_item_button.hidden = true
        edit_board_button.hidden = true
        delete_board_button.hidden = true
        
        save_item_button.hidden = true
        save_board_button.hidden = false
        cancel_button.hidden = false
    }
    
    func reloadItems()
    {
        board.items = item_dao.fetchItemsForBoard(board.id!)
        tip_view.hidden = board.items.count != 0
        tableView.reloadData()
        item_progress.progress = Float(board.getCompletionPerc())
    }
    
    // SwipeCellDelegate methods
    
    func markItemAsComplete(cell:BoardTableViewCell)
    {
        cell.item.status = Status.Completed
        performItemUpdate(cell)
    }
    
    func markItemAsWillNotComplete(cell:BoardTableViewCell)
    {
        cell.item.status = Status.Will_Not_Complete
        performItemUpdate(cell)
    }
    
    func performItemUpdate(cell:BoardTableViewCell)
    {
        cell.closeCell()
        item_dao.updateItem(cell.item)
        cellDidClose(cell)
        reloadItems()
    }
    
    func cellDidOpen(cell:BoardTableViewCell)
    {
        var current_path:NSIndexPath = tableView.indexPathForCell(cell)!
        cells_currently_editing.addObject(current_path)
    }
    
    func cellDidClose(cell:BoardTableViewCell)
    {
        var current_path:NSIndexPath = tableView.indexPathForCell(cell)!
        cells_currently_editing.removeObject(current_path)
    }
}

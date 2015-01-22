//
//  ItemViewController.swift
//  ToDoList
//
//  Created by Jacob Sanchez on 12/23/14.
//  Copyright (c) 2014 JSanch. All rights reserved.

import UIKit

class ItemViewController: UIViewController,UIAlertViewDelegate
{
    // main view
    @IBOutlet var status_view:UIView!
    @IBOutlet var day_view:UIView!
    @IBOutlet var status_label:UILabel!
    @IBOutlet var event_label:UILabel!
    @IBOutlet var outer_image_view:UIView!
    @IBOutlet var inner_image_view:UIView!
    @IBOutlet var priority_image:UIImageView!
    @IBOutlet var description_view:UITextView!
    
    // settings pane
    @IBOutlet var edit_button:UIButton!
    @IBOutlet var move_button:UIButton!
    @IBOutlet var delete_button:UIButton!
    @IBOutlet var save_item_button:UIButton!
    @IBOutlet var confirm_move_button:UIButton!
    @IBOutlet var cancel_edit_button:UIButton!
    
    // slide in views
    @IBOutlet var editorview_spacefrombottom:NSLayoutConstraint!
    @IBOutlet var editorview_height:NSLayoutConstraint!
    @IBOutlet var settings_pane_top:NSLayoutConstraint!
    
    @IBOutlet var move_item_view:BoardsDetailView!
    @IBOutlet var moveitem_spacefrombottom:NSLayoutConstraint!
    
    @IBOutlet var editor_view:ItemDetailView!
    
    var item_dao:ItemDataAccess
    var board:Board // for move item view
    var item:Item

    // button set constants
    let CURRENT_BUTTONS = 0
    let DEFAULT_BUTTONS = 1
    let EDITOR_BUTTONS = 2
    let MOVE_ITEM_BUTTONS = 3
    
    init(nibName nibNameOrNil:String!, bundle nibBundleOrNil:NSBundle!, item:Item, board:Board)
    {
        self.item = item
        self.board = board
        item_dao = ItemDataAccess()
        
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    required init(coder aDecoder:NSCoder)
    {
        item = Item()
        board = Board()
        item_dao = ItemDataAccess()
        
        super.init(coder:aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // settings bar button
        var settings_button:UIBarButtonItem = UIBarButtonItem(image:UIImage(named:"gear"), style:UIBarButtonItemStyle.Plain, target:self, action:"settingsGearTapped")
        self.navigationItem.rightBarButtonItem = settings_button
        
        // settings pane
        var button_array:[UIButton] = [edit_button, delete_button, save_item_button, cancel_edit_button, move_button, confirm_move_button]
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
        
        loadDisplay()
        displayButtonSet(DEFAULT_BUTTONS)
        description_view.editable = false
        
        move_item_view.initializeLabel("Select Destination Board")
    }
    
    func loadDisplay()
    {
        self.title = item.title
        status_label.text = item.status.description
        description_view.text = item.description
        
        // status color
        switch item.status
        {
            case Status.Not_Started:
                status_view.backgroundColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha: 1.0)
                break
            case Status.In_Progress:
                status_view.backgroundColor = UIColor(red:1.0, green:1.0, blue:0.5, alpha: 1.0)
                break
            case Status.Completed:
                status_view.backgroundColor = UIColor(red:0.5, green:1.0, blue:0.5, alpha: 1.0)
                break
            case Status.Will_Not_Complete:
                status_view.backgroundColor = UIColor(red:1.0, green:0.5, blue:0.5, alpha: 1.0)
                break
            default:
                status_view.backgroundColor = UIColor.whiteColor()
        }
        
        // event label naming
        event_label.text = item.is_task ? ((item.day == Day.None) ? "Task" : "Task Due \(item.day.description)") : ((item.day == Day.None) ? "Event" : "Event On \(item.day.description)")
        
        // image display
        outer_image_view.layer.cornerRadius = 18
        outer_image_view.clipsToBounds = true
        
        inner_image_view.layer.cornerRadius = 17
        inner_image_view.clipsToBounds = true
        
        // priority flag
        if !item.isCompleted()
        {
            switch item.priority
            {
            case Priority.Low:
                priority_image.image = UIImage(named:"low")
                break
            case Priority.Medium:
                priority_image.image = UIImage(named:"medium")
                break
            case Priority.High:
                priority_image.image = UIImage(named:"high")
                break
            default:
                priority_image.image = nil
            }
            
            outer_image_view.hidden = false
            inner_image_view.hidden = false
        }
        else
        {
            priority_image.image = nil
            outer_image_view.hidden = true
            inner_image_view.hidden = true
        }
    
        hackatizeMeCaptain()
    }
    
    func hackatizeMeCaptain()
    {
        // close-open-close hack to fix pop layout
        setDefaultEditorConstraints()
        view.layoutIfNeeded()
        
        editorview_spacefrombottom.constant = 0
        view.layoutIfNeeded()
        
        setDefaultEditorConstraints()
        view.layoutIfNeeded()
    }
    
    func setDefaultEditorConstraints()
    {
        // getting editor specs just right ;)
        var height:CGFloat = UIScreen.mainScreen().bounds.height - 64 // 44 from nav bar, 20 from status bar
        editorview_height.constant = height
        editorview_spacefrombottom.constant = -1 * height
        editor_view.setViewDimensions(height)
    }
    
    func settingsGearTapped()
    {
        toggleSettingsPane(CURRENT_BUTTONS)
    }
    
    func toggleSettingsPane(button_set:Int)
    {
        settings_pane_top.constant = settings_pane_top.constant == 0 ? -100 : 0
        UIView.animateWithDuration(0.5, animations: {
            self.view.layoutIfNeeded()
        }, completion: {
            (value: Bool) in
            self.displayButtonSet(button_set)
        })
    }
    
    @IBAction func editTapped()
    {
        toggleSettingsPane(EDITOR_BUTTONS)
        editor_view.displayItem(item)
        
        self.title = "Edit \(item.title)"
        openEditorView()
    }
    
    @IBAction func moveItemTapped()
    {
        move_item_view.reloadBoards(BoardDataAccess().fetchBoards(), selected_board:board)
        toggleSettingsPane(MOVE_ITEM_BUTTONS)
        
        self.title = "Move Item"
        openMoveItemView()
    }
    
    @IBAction func cancelTapped()
    {
        toggleSettingsPane(DEFAULT_BUTTONS)
        closeEditorView()
        closeMoveItemView()
    }
    
    @IBAction func saveTapped()
    {
        toggleSettingsPane(DEFAULT_BUTTONS)
        closeEditorView()
        loadDisplay()
        
        item = editor_view.getUpdatedItem()
        item_dao.updateItem(item)
    }
    
    @IBAction func confirmItemMove()
    {
        toggleSettingsPane(DEFAULT_BUTTONS)
        closeMoveItemView()
        
        var dest_board:Board? = move_item_view.getSelectedBoard()
        if dest_board != nil && !dest_board!.isEqualTo(board) // selected different destination board
        {
            board = dest_board!
            item.board_id = dest_board?.id
            ItemDataAccess().updateItem(item)
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    func openEditorView()
    {
        editorview_spacefrombottom.constant = 0
        UIView.animateWithDuration(0.5, animations:{
            self.view.layoutIfNeeded()
        })
    }
    
    func closeEditorView()
    {
        editorview_spacefrombottom.constant = -1 * (UIScreen.mainScreen().bounds.height - 64)
        UIView.animateWithDuration(0.5, animations:{
            self.view.layoutIfNeeded()
        }, completion: {
            (value: Bool) in
            self.title = self.item.title
        })
    }
    
    func openMoveItemView()
    {
        moveitem_spacefrombottom.constant = 0
        UIView.animateWithDuration(0.5, animations:{
            self.view.layoutIfNeeded()
        })
    }
    
    func closeMoveItemView()
    {
        moveitem_spacefrombottom.constant = -250
        UIView.animateWithDuration(0.5, animations:{
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func deleteTapped()
    {
        var alert:UIAlertView = UIAlertView(title:"WARNING", message:"Once deleted, this item cannot be recovered.", delegate:self, cancelButtonTitle:"Cancel", otherButtonTitles: "Delete Item")
        alert.show()
    }
    
    func alertView(alertView:UIAlertView, didDismissWithButtonIndex buttonIndex:Int)
    {
        if buttonIndex == 1
        {
            item_dao.removeItem(item)
            self.navigationController?.popViewControllerAnimated(true)
        }
        toggleSettingsPane(DEFAULT_BUTTONS)
    }
    
    func displayButtonSet(button_set:Int)
    {
        switch button_set
        {
            case CURRENT_BUTTONS:
                break
            case DEFAULT_BUTTONS:
                displayDefaultButtons()
                break
            case EDITOR_BUTTONS:
                displayEditItemButtons()
                break
            case MOVE_ITEM_BUTTONS:
                displayMoveItemButtons()
                break
            default:
                break
        }
    }
    
    func displayDefaultButtons()
    {
        edit_button.hidden = false
        move_button.hidden = false
        delete_button.hidden = false
    
        save_item_button.hidden = true
        confirm_move_button.hidden = true
        cancel_edit_button.hidden = true
    }
    
    func displayEditItemButtons()
    {
        edit_button.hidden = true
        move_button.hidden = true
        delete_button.hidden = true
        confirm_move_button.hidden = true
        
        save_item_button.hidden = false
        cancel_edit_button.hidden = false
    }
    
    func displayMoveItemButtons()
    {
        
        edit_button.hidden = true
        move_button.hidden = true
        delete_button.hidden = true
        save_item_button.hidden = true
        
        confirm_move_button.hidden = false
        cancel_edit_button.hidden = false
    }
}

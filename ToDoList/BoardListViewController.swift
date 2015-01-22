//
//  BoardListViewController.swift
//  ToDoList
//
//  Created by Jacob Sanchez on 12/21/14.
//  Copyright (c) 2014 JSanch. All rights reserved.

import UIKit

class BoardListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet var tableView:UITableView!
    @IBOutlet var tip_view:UIView!
    
    // settings pane
    @IBOutlet var settings_pane_top:NSLayoutConstraint!
    @IBOutlet var add_board_button:UIButton!
    @IBOutlet var edit_boards_button:UIButton!
    @IBOutlet var create_board_button:UIButton!
    @IBOutlet var save_board_settings_button:UIButton!
    @IBOutlet var cancel_creation_button:UIButton!
    
    // add board view
    @IBOutlet var add_board_view:BoardDetailView!
    @IBOutlet var add_board_topspace:NSLayoutConstraint!
    
    // boards detail view
    @IBOutlet var boards_detail_view:BoardsDetailView!
    @IBOutlet var boards_detail_bottomspace:NSLayoutConstraint!
    
    var board_dao:BoardDataAccess
    var selected_board:Board?
    var boards:[Board]
    
    // constants for which button view to display
    let CURRENT_BUTTONS = 0
    let DEFAULT_BUTTONS = 1
    let CREATE_BOARD_BUTTONS = 2
    let SELECT_BOARD_BUTTONS = 3
    
    required init(coder aDecoder:NSCoder)
    {
        board_dao = BoardDataAccess()
        boards = board_dao.fetchBoards()
        super.init(coder:aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "BoardListTableViewCell",
                    bundle: NSBundle.mainBundle()), forCellReuseIdentifier:"BoardListCell")
        tip_view.hidden = boards.count != 0
        setSelectedBoard()
        
        // settings bar button
        var settings_button:UIBarButtonItem = UIBarButtonItem(image:UIImage(named:"gear"), style:UIBarButtonItemStyle.Plain, target:self, action:"settingsButtonTapped")
        self.navigationItem.rightBarButtonItem = settings_button
        
        // settings pane
        var button_array:[UIButton] = [add_board_button, edit_boards_button, create_board_button, cancel_creation_button,save_board_settings_button]
        for button in button_array
        {
            button.layer.borderColor = UIColor.redColor().CGColor
            button.layer.borderWidth = 2
            button.layer.cornerRadius = 10
            button.clipsToBounds = true
            
            button.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
            button.titleLabel?.textAlignment = NSTextAlignment.Center
            button.titleLabel?.font = UIFont.systemFontOfSize(17)
        }
        
        settings_pane_top.constant = -100
        showDefaultButtons()
        
        // move later
        boards_detail_view.initializeLabel("Select Current Board")
    }
    
    override func viewWillAppear(animated: Bool)
    {
        if tableView.indexPathForSelectedRow() != nil
        {
            tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow()!, animated:true)
            reloadBoards()
        }
        super.viewDidAppear(animated)
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return boards.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:BoardListTableViewCell = tableView.dequeueReusableCellWithIdentifier("BoardListCell") as BoardListTableViewCell
        
        cell.board = self.boards[indexPath.row]
        cell.loadDisplay()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var b:Board = boards[indexPath.row]
        var controller:BoardViewController = BoardViewController(nibName:"BoardViewController",
                                                                  bundle:NSBundle.mainBundle(),
                                                                   board:b)
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
            (value: Bool) in
            self.displayButtons(button_set)
        })
    }
    
    @IBAction func addBoardTapped()
    {
        add_board_view.displayDefaultBoard()
        toggleSettingsPane(CREATE_BOARD_BUTTONS)
        openAddBoardView()
    }
    
    @IBAction func editBoardsTapped()
    {
        toggleSettingsPane(SELECT_BOARD_BUTTONS)
        boards_detail_view.reloadBoards(boards, selected_board:selected_board)
        openBoardsDetailView()
    }
    
    @IBAction func cancelBoardCreation()
    {
        toggleSettingsPane(DEFAULT_BUTTONS)
        closeAddBoardView()
        closeBoardsDetailView()
    }
    
    @IBAction func createBoard()
    {
        var new_board:Board = add_board_view.getUpdatedBoard()
        board_dao.addBoard(new_board)
        reloadBoards()
        
        toggleSettingsPane(DEFAULT_BUTTONS)
        closeAddBoardView()
    }
    
    @IBAction func saveBoardSettings()
    {
        toggleSettingsPane(DEFAULT_BUTTONS)
        closeBoardsDetailView()
        setBoardAsSelected(boards_detail_view.getSelectedBoard())
        board_dao.updateAllBoards(boards)
        reloadBoards()
    }
    
    func openAddBoardView()
    {
        add_board_topspace.constant = 0
        UIView.animateWithDuration(0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func closeAddBoardView()
    {
        add_board_topspace.constant = -135
        UIView.animateWithDuration(0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func openBoardsDetailView()
    {
        boards_detail_bottomspace.constant = 0
        UIView.animateWithDuration(0.5, animations:{
            self.view.layoutIfNeeded()
        })
    }
    
    func closeBoardsDetailView()
    {
        boards_detail_bottomspace.constant = -250
        UIView.animateWithDuration(0.5, animations:{
            self.view.layoutIfNeeded()
        })
    }
    
    func displayButtons(button_set:Int)
    {
        switch button_set
        {
            case CURRENT_BUTTONS:
                break
            case DEFAULT_BUTTONS:
                showDefaultButtons()
                break
            case CREATE_BOARD_BUTTONS:
                showBoardCreationButtons()
                break
            case SELECT_BOARD_BUTTONS:
                showBoardDetailButtons()
                break
            default:
                break
        }
    }
    
    func showDefaultButtons()
    {
        add_board_button.hidden = false
        edit_boards_button.hidden = false
        
        create_board_button.hidden = true
        cancel_creation_button.hidden = true
        
        save_board_settings_button.hidden = true
    }
    
    func showBoardCreationButtons()
    {
        add_board_button.hidden = true
        edit_boards_button.hidden = true
        
        create_board_button.hidden = false
        cancel_creation_button.hidden = false
        
        save_board_settings_button.hidden = true
    }
    
    func showBoardDetailButtons()
    {
        add_board_button.hidden = true
        edit_boards_button.hidden = true
        
        create_board_button.hidden = true
        
        save_board_settings_button.hidden = false
        cancel_creation_button.hidden = false
    }
    
    func reloadBoards()
    {
        boards = board_dao.fetchBoards()
        tip_view.hidden = boards.count != 0
        tableView.reloadData()
        setSelectedBoard()
    }
    
    func setSelectedBoard()
    {
        for board in boards
        {
            if board.selected
            {
                selected_board = board
            }
        }
    }
    
    func setBoardAsSelected(s_board:Board?)
    {
        for board in boards
        {
            board.selected = s_board != nil && board.isEqualTo(s_board!)
        }
    }
}


//
//  ItemDetailView.swift
//  ToDoList
//
//  Created by Jacob Sanchez on 1/4/15.
//  Copyright (c) 2015 JSanch. All rights reserved.

import UIKit

class ItemDetailView: UIView
{
    // top fields
    @IBOutlet var title_field:UITextField!
    @IBOutlet var description_field:UITextView!
    
    // bottom label views
    @IBOutlet var view:UIView!
    @IBOutlet var type_view:UIView!
    @IBOutlet var status_view:UIView!
    @IBOutlet var day_view:UIView!
    @IBOutlet var priority_view:UIView!
    
    // bottom labels
    @IBOutlet var type_label:UILabel!
    @IBOutlet var status_label:UILabel!
    @IBOutlet var day_label:UILabel!
    @IBOutlet var priority_label:UILabel!
    
    // bottom views
    @IBOutlet var label_view:UIView!
    @IBOutlet var selection_view:UIView!
    
    // type
    @IBOutlet var type_selection_view:UIView!
    @IBOutlet var task_type_button:UIButton!
    @IBOutlet var event_type_button:UIButton!
    
    // status
    @IBOutlet var status_selection_view:UIView!
    @IBOutlet var not_started_button:UIButton!
    @IBOutlet var in_progress_button:UIButton!
    @IBOutlet var completed_button:UIButton!
    @IBOutlet var will_not_complete_button:UIButton!
    
    // priority
    @IBOutlet var priority_selection_view:UIView!
    @IBOutlet var low_priority_button:UIButton!
    @IBOutlet var medium_priority_button:UIButton!
    @IBOutlet var high_priority_button:UIButton!
    
    // day
    @IBOutlet var day_selection_view:UIView!
    @IBOutlet var sunday_button:UIButton!
    @IBOutlet var monday_button:UIButton!
    @IBOutlet var tuesday_button:UIButton!
    @IBOutlet var wednesday_button:UIButton!
    @IBOutlet var thursday_button:UIButton!
    @IBOutlet var friday_button:UIButton!
    @IBOutlet var saturday_button:UIButton!
    @IBOutlet var no_day_button:UIButton!
    
    // selection animation
    @IBOutlet var label_view_width:NSLayoutConstraint!
    @IBOutlet var selection_view_width:NSLayoutConstraint!
    @IBOutlet var label_view_left_offset:NSLayoutConstraint!
    
    var device_width:CGFloat
    var item:Item
    
    required init(coder aDecoder: NSCoder)
    {
        item = Item()
        device_width = 0
        
        super.init(coder:aDecoder)
        NSBundle.mainBundle().loadNibNamed("ItemDetailView",owner:self,options:nil)
        self.addSubview(self.view)
    }
    
    func setViewDimensions(new_height:CGFloat)
    {
        var new_frame_size:CGSize = CGSize(width:CGRectGetWidth(view.frame), height:new_height)
        var new_frame:CGRect = CGRect(origin:view.frame.origin, size:new_frame_size)
        view.frame = new_frame
        
        // lower view constraints
        device_width = UIScreen.mainScreen().bounds.width
        label_view_width.constant = device_width
        selection_view_width.constant = device_width
        label_view_left_offset.constant = 0
    }
    
    func displayDefaultItem()
    {
        self.item = Item()
        refreshDisplay()
        initializeDisplay()
    }
    
    func displayItem(item:Item)
    {
        self.item = item
        refreshDisplay()
        initializeDisplay()
    }
    
    func initializeDisplay()
    {
        // views
        var view_array:[UIView] = [type_view, status_view, priority_view, day_view, task_type_button, event_type_button, not_started_button, in_progress_button, completed_button, will_not_complete_button, low_priority_button, medium_priority_button, high_priority_button, sunday_button, monday_button, tuesday_button, wednesday_button, thursday_button, friday_button, saturday_button, no_day_button]
        for view in view_array
        {
            view.layer.cornerRadius = 10
            view.clipsToBounds = true
        }
        
        var tap:UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:"dismissKeyboards")
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboards()
    {
        title_field.resignFirstResponder()
        description_field.resignFirstResponder()
    }
    
    func refreshDisplay()
    {
        title_field.text = item.title
        description_field.text = item.description
        type_label.text = item.is_task ? "Task" : "Event"
        status_label.text = item.status.description
        priority_label.text = "\(item.priority.description) Priority"
        day_label.text = item.day.description
    }
    
    func storeFieldValues()
    {
        item.title = title_field.text
        item.description = description_field.text
    }
    
    func getUpdatedItem() -> Item
    {
        storeFieldValues()
        item.title = (item.title == "") ? "Title" : item.title
        return item
    }
    
    @IBAction func changeType()
    {
        removePreviousSelectionView()
        storeFieldValues()
        
        selection_view.addSubview(type_selection_view);
        type_selection_view.bounds.size = selection_view.bounds.size
        type_selection_view.frame.origin = CGPoint(x:0,y:0)
        
        toggleSelectionView()
    }
    
    @IBAction func changeStatus()
    {
        removePreviousSelectionView()
        storeFieldValues()
        
        selection_view.addSubview(status_selection_view);
        status_selection_view.bounds.size = selection_view.bounds.size
        status_selection_view.frame.origin = CGPoint(x:0,y:0)
        
        toggleSelectionView()
    }
    
    @IBAction func changePriority()
    {
        removePreviousSelectionView()
        storeFieldValues()
        
        selection_view.addSubview(priority_selection_view);
        priority_selection_view.bounds.size = selection_view.bounds.size
        priority_selection_view.frame.origin = CGPoint(x:0,y:0)
        
        toggleSelectionView()
    }
    
    @IBAction func changeDay()
    {
        removePreviousSelectionView()
        storeFieldValues()
        
        selection_view.addSubview(day_selection_view);
        day_selection_view.bounds.size = selection_view.bounds.size
        day_selection_view.frame.origin = CGPoint(x:0,y:0)
        
        toggleSelectionView()
    }
    
    func removePreviousSelectionView()
    {
        for view in selection_view.subviews
        {
            view.removeFromSuperview()
        }
    }
    
    func toggleSelectionView()
    {
        label_view_left_offset.constant = (label_view_left_offset.constant == 0) ? -1 * device_width : 0
        UIView.animateWithDuration(0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    // TYPE BUTTONS
    
    @IBAction func taskTypePressed()
    {
        item.is_task = true
        refreshDisplay()
        toggleSelectionView()
    }
    
    @IBAction func eventTypePressed()
    {
        item.is_task = false
        refreshDisplay()
        toggleSelectionView()
    }
    
    // STATUS BUTTONS
    
    @IBAction func notStartedPressed()
    {
        item.status = Status.Not_Started
        refreshDisplay()
        toggleSelectionView()
    }
    
    @IBAction func inProgressPressed()
    {
        item.status = Status.In_Progress
        refreshDisplay()
        toggleSelectionView()
    }
    
    @IBAction func completedPressed()
    {
        item.status = Status.Completed
        refreshDisplay()
        toggleSelectionView()
    }
    
    @IBAction func willNotCompletePressed()
    {
        item.status = Status.Will_Not_Complete
        refreshDisplay()
        toggleSelectionView()
    }
    
    // PRIORITY BUTTONS
    
    @IBAction func lowPriorityPressed()
    {
        item.priority = Priority.Low
        refreshDisplay()
        toggleSelectionView()
    }
    
    @IBAction func mediumPriorityPressed()
    {
        item.priority = Priority.Medium
        refreshDisplay()
        toggleSelectionView()
    }
    
    @IBAction func highPriorityPressed()
    {
        item.priority = Priority.High
        refreshDisplay()
        toggleSelectionView()
    }
    
    // DAY BUTTONS
    
    @IBAction func sundayPressed()
    {
        item.day = Day.Sunday
        refreshDisplay()
        toggleSelectionView()
    }
    
    @IBAction func mondayPressed()
    {
        item.day = Day.Monday
        refreshDisplay()
        toggleSelectionView()
    }
    
    @IBAction func tuesdayPressed()
    {
        item.day = Day.Tuesday
        refreshDisplay()
        toggleSelectionView()
    }
    
    @IBAction func wednesdayPressed()
    {
        item.day = Day.Wednesday
        refreshDisplay()
        toggleSelectionView()
    }
    
    @IBAction func thursdayPressed()
    {
        item.day = Day.Thursday
        refreshDisplay()
        toggleSelectionView()
    }
    
    @IBAction func fridayPressed()
    {
        item.day = Day.Friday
        refreshDisplay()
        toggleSelectionView()
    }
    
    @IBAction func saturdayPressed()
    {
        item.day = Day.Saturday
        refreshDisplay()
        toggleSelectionView()
    }
    
    @IBAction func noDayPressed()
    {
        item.day = Day.None
        refreshDisplay()
        toggleSelectionView()
    }
}

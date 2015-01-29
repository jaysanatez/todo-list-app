//
//  BoardTableViewCell.swift
//  ToDoList
//
//  Created by Jacob Sanchez on 12/23/14.
//  Copyright (c) 2014 JSanch. All rights reserved.

import UIKit

protocol SwipeCellDelegate
{
    func markItemAsComplete(cell:BoardTableViewCell)
    func markItemAsWillNotComplete(cell:BoardTableViewCell)
    func cellDidOpen(cell:BoardTableViewCell)
    func cellDidClose(cell:BoardTableViewCell)
}

class BoardTableViewCell: UITableViewCell
{   
    @IBOutlet var title_label:UILabel!
    @IBOutlet var priority_image:UIImageView!
    @IBOutlet var status_color:UIView!
    @IBOutlet var day_label:UILabel!
    
    // swiping is fun
    @IBOutlet var content_view_right_constraint:NSLayoutConstraint!
    @IBOutlet var content_view_left_constraint:NSLayoutConstraint!
    var pan_recognizer:UIPanGestureRecognizer?
    var pan_start_point:CGPoint?
    var starting_right_layout_constraint_constant:CGFloat?
    
    let kBounceValue:CGFloat = 20.0
    
    // quick update button stuff
    @IBOutlet var cover_view:UIView!
    @IBOutlet var button_view:UIView!
    @IBOutlet var wnc_button:UIButton!
    @IBOutlet var comp_button:UIButton!
    
    var delegate:SwipeCellDelegate?
    var item:Item
    
    required init(item:Item)
    {
        self.item = item
        super.init()
    }
    
    required init(coder aDecoder:NSCoder)
    {
        item = Item()
        super.init(coder:aDecoder)
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.pan_recognizer = UIPanGestureRecognizer(target:self, action:"panThisCell:")
        self.pan_recognizer?.delegate = self
        self.cover_view.addGestureRecognizer(self.pan_recognizer!)
        
        // hidden button format
        var button_array:[UIButton] = [wnc_button, comp_button]
        for button in button_array
        {
            button.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
            button.titleLabel?.textAlignment = NSTextAlignment.Center
            button.titleLabel?.font = UIFont.systemFontOfSize(15)
        }
        
        comp_button.backgroundColor = UIColor(red:0.5, green:1.0, blue:0.5, alpha:1.0)
        wnc_button.backgroundColor = UIColor(red:1.0, green:0.5, blue:0.5, alpha:1.0)
    }
    
    func loadDisplay()
    {
        title_label.text = item.title
        title_label.adjustsFontSizeToFitWidth = true
        
        // status bar color
        switch item.status
        {
            case Status.Not_Started:
                status_color.backgroundColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha: 1.0)
                break
            case Status.In_Progress:
                status_color.backgroundColor = UIColor(red:1.0, green:1.0, blue:0.5, alpha: 1.0)
                break
            case Status.Completed:
                status_color.backgroundColor = UIColor(red:0.5, green:1.0, blue:0.5, alpha: 1.0)
                break
            case Status.Will_Not_Complete:
                status_color.backgroundColor = UIColor(red:1.0, green:0.5, blue:0.5, alpha: 1.0)
                break
            default:
                status_color.backgroundColor = UIColor.whiteColor()
        }
        
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
        }
        else
        {
            priority_image.image = nil
        }

        day_label.text = item.is_task ? ((item.day == Day.None) ? "Task - No Specific Due Date" : "Task Due \(item.day.description)") : ((item.day == Day.None) ? "Event - No Specific Date" : "Event On \(item.day.description)")
    }
    
    /* 
        SWIPE STUFFS, props to:
        http://www.raywenderlich.com/62435/make-swipeable-table-view-cell-actions-without-going-nuts-scroll-views
    */
    
    func panThisCell(recognizer:UIPanGestureRecognizer)
    {
        switch recognizer.state
        {
            case UIGestureRecognizerState.Began:
                self.pan_start_point = recognizer.translationInView(cover_view)
                starting_right_layout_constraint_constant = content_view_right_constraint.constant
                break
            case UIGestureRecognizerState.Changed:
                var current_point:CGPoint = recognizer.translationInView(cover_view)
                var delta_x:CGFloat = current_point.x - pan_start_point!.x
                var panning_left:Bool = current_point.x < pan_start_point!.x
        
                if starting_right_layout_constraint_constant == 0
                {
                    if !panning_left
                    {
                        var constant:CGFloat = max(-1 * delta_x, 0)
                        if constant == 0
                        {
                            resetConstraintConstantsToZero(true, notifyDelegate:false)
                        }
                        else
                        {
                            content_view_right_constraint.constant = constant
                        }
                    }
                    else
                    {
                        var constant:CGFloat = min(-1 * delta_x, totalButtonWidth())
                        if constant == totalButtonWidth()
                        {
                            setConstraintsToShowAllButtons(true, notifyDelegate:false)
                        }
                        else
                        {
                            content_view_right_constraint.constant = constant
                        }
                    }
                }
                else
                {
                    var adjustment:CGFloat = starting_right_layout_constraint_constant! - delta_x
                    if !panning_left
                    {
                        var constant:CGFloat = max(adjustment, 0)
                        if constant == 0
                        {
                            resetConstraintConstantsToZero(true, notifyDelegate:false)
                        }
                        else
                        {
                            content_view_right_constraint.constant = constant
                        }
                    }
                    else
                    {
                        var constant:CGFloat = min(adjustment, totalButtonWidth())
                        if constant == totalButtonWidth()
                        {
                            setConstraintsToShowAllButtons(true, notifyDelegate:false)
                        }
                        else
                        {
                            content_view_right_constraint.constant = constant
                        }
                    }
                }
            
                content_view_left_constraint.constant = -content_view_right_constraint.constant
                break
            case UIGestureRecognizerState.Ended:
                if starting_right_layout_constraint_constant == 0
                {
                    if content_view_right_constraint.constant >= 60
                    {
                        setConstraintsToShowAllButtons(true, notifyDelegate:true)
                    }
                    else
                    {
                        resetConstraintConstantsToZero(true, notifyDelegate:true)
                    }
                }
                else
                {
                    if content_view_right_constraint.constant >= 100
                    {
                        setConstraintsToShowAllButtons(true, notifyDelegate:true)
                    }
                    else
                    {
                        resetConstraintConstantsToZero(true, notifyDelegate:true)
                    }
                }
                break
            case UIGestureRecognizerState.Cancelled:
                break
            default:
                break
        }
    }
    
    func totalButtonWidth() -> CGFloat
    {
        return CGRectGetWidth(self.frame) - CGRectGetMinX(self.button_view.frame)
    }
    
    func resetConstraintConstantsToZero(animated:Bool, notifyDelegate:Bool)
    {
        if notifyDelegate
        {
            delegate!.cellDidClose(self)
        }
        
        if starting_right_layout_constraint_constant != 0 || content_view_right_constraint.constant != 0
        {
            content_view_left_constraint.constant = -kBounceValue
            content_view_right_constraint.constant = kBounceValue
        
            updateConstraintsIfNeeded(animated, completion: {
                (finished:Bool) in
                self.content_view_left_constraint.constant = 0
                self.content_view_right_constraint.constant = 0
            
                self.updateConstraintsIfNeeded(animated, completion:{
                    (finished:Bool) in
                    self.starting_right_layout_constraint_constant = self.content_view_right_constraint.constant
                })
            })
        }
    }
    
    func setConstraintsToShowAllButtons(animated:Bool, notifyDelegate:Bool)
    {
        if notifyDelegate
        {
            delegate!.cellDidOpen(self)
        }
        
        if starting_right_layout_constraint_constant != totalButtonWidth() || content_view_right_constraint.constant != totalButtonWidth()
        {
            content_view_left_constraint.constant = -1 * (totalButtonWidth() + kBounceValue)
            content_view_right_constraint.constant = totalButtonWidth() + kBounceValue
        
            updateConstraintsIfNeeded(animated, completion: {
                (finished:Bool) in
                self.content_view_left_constraint.constant = -1 * self.totalButtonWidth()
                self.content_view_right_constraint.constant = self.totalButtonWidth()
            
                self.updateConstraintsIfNeeded(animated, completion:{
                    (finished:Bool) in
                    self.starting_right_layout_constraint_constant = self.content_view_right_constraint.constant
                })
            })
        }
    }
    
    func updateConstraintsIfNeeded(animated:Bool, completion:((finished:Bool) -> Void))
    {
        [UIView .animateWithDuration(animated ? 0.1 : 0, delay:0.0, options:UIViewAnimationOptions.CurveEaseOut, animations:{
                self.layoutIfNeeded()
        }, completion:completion)]
    }
    
    // to play nice with the table view
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
            return true
    }
    
    // to avoid stupid reuse bug
    override func prepareForReuse()
    {
        super.prepareForReuse()
        resetConstraintConstantsToZero(false, notifyDelegate:false)
    }
    
    // lets delegate open cells
    func openCell()
    {
        setConstraintsToShowAllButtons(false, notifyDelegate:false)
    }
    
    func closeCell()
    {
        resetConstraintConstantsToZero(false, notifyDelegate:false)
    }
    
    // hidden button actions
    @IBAction func closeCellAsComplete()
    {
        self.closeCell({
            (finished:Bool) in
            self.delegate!.markItemAsComplete(self)
        })
    }
    
    @IBAction func closeCellAsWillNotComplete()
    {
        self.closeCell({
            (finished:Bool) in
            self.delegate!.markItemAsWillNotComplete(self)
        })
    }
    
    func closeCell(completion:((finished:Bool) -> Void))
    {
        content_view_left_constraint.constant = 0
        content_view_right_constraint.constant = 0
        UIView.animateWithDuration(0.25, delay:0.0, options:UIViewAnimationOptions.CurveEaseOut, animations:{
            self.layoutIfNeeded()
        }, completion:completion)
    }
}
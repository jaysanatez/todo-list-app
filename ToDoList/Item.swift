//
//  Item.swift
//  ToDoList
//
//  Created by Jacob Sanchez on 12/21/14.
//  Copyright (c) 2014 JSanch. All rights reserved.

import CoreData

class Item
{
    var board_id:String?
    var cd_object:NSManagedObject?
    
    var title:String
    var description:String
    var is_task:Bool
    
    var status:Status
    var priority:Priority
    var day:Day
    
    // Defaults
    let DEFAULT_TITLE = ""
    let DEFAULT_DESCRIPTION = ""
    let DEFAULT_IS_TASK = true
    let DEFAULT_STATUS = Status.Not_Started
    let DEFAULT_PRIORITY = Priority.Medium
    let DEFAULT_DAY = Day.None
    
    // default constructor
    init()
    {
        title = DEFAULT_TITLE
        description = DEFAULT_DESCRIPTION
        is_task = DEFAULT_IS_TASK
        
        status = DEFAULT_STATUS
        priority = DEFAULT_PRIORITY
        day = DEFAULT_DAY
    }
    
    // constructor for retrieval
    init(cd_object:NSManagedObject)
    {
        self.cd_object = cd_object
        
        board_id = cd_object.valueForKey("board_id") as? String
        title = cd_object.valueForKey("title") as String
        description = cd_object.valueForKey("descr") as String
        is_task = (cd_object.valueForKey("type") as String) == "Task"
        
        // stupid hack cuz swift is dumb
        status = DEFAULT_STATUS
        priority = DEFAULT_PRIORITY
        day = DEFAULT_DAY
        
        // parse strings into enums
        status = self.parseStatus(cd_object.valueForKey("status") as String)
        priority = self.parsePriority(cd_object.valueForKey("priority") as String)
        day = self.parseDay(cd_object.valueForKey("day") as String)
    }
    
    func parseStatus(raw_status:String) -> Status
    {
        switch raw_status
        {
            case "Not_Started":
                return Status.Not_Started
            case "In_Progress":
                return Status.In_Progress
            case "Completed":
                return Status.Completed
            case "Will_Not_Complete":
                return Status.Will_Not_Complete
            default:
                return Status.Not_Started
        }
    }
    
    func parsePriority(raw_priority:String) -> Priority
    {
        switch raw_priority
        {
            case "Low":
                return Priority.Low
            case "Medium":
                return Priority.Medium
            case "High":
                return Priority.High
            default:
                return Priority.Medium
        }
    }
    
    func parseDay(raw_day:String) -> Day
    {
        switch raw_day
        {
            case "Sunday":
                return Day.Sunday
            case "Monday":
                return Day.Monday
            case "Tuesday":
                return Day.Tuesday
            case "Wednesday":
                return Day.Wednesday
            case "Thursday":
                return Day.Thursday
            case "Friday":
                return Day.Friday
            case "Saturday":
                return Day.Saturday
            case "None":
                return Day.None
            default:
                return Day.None
        }
    }
    
    // constructor for creation
    init(title:String, description:String, is_task:Bool, status:Status, priority:Priority, day:Day)
    {
        self.title = title
        self.description = description
        self.is_task = is_task
        self.status = status
        self.priority = priority
        self.day = day
    }
    
    func isCompleted() -> Bool
    {
        return status == Status.Completed || status == Status.Will_Not_Complete
    }
    
    func hasStatusLessThanItem(i2:Item) -> Bool
    {
        // swap if false
        switch status
        {
            case Status.In_Progress:
                return true
            case Status.Not_Started:
                return i2.status != Status.In_Progress
            case Status.Completed:
                return i2.isCompleted()
            case Status.Will_Not_Complete:
                return i2.status == Status.Will_Not_Complete
            default:
                return false
        }
    }
    
    func hasPriorityLessThanItem(i2:Item) -> Bool
    {
        // swap if false
        switch priority
        {
            case Priority.Low:
                return i2.priority == Priority.Low
            case Priority.Medium:
                return i2.priority == Priority.Low || i2.priority == Priority.Medium
            case Priority.High:
                return true
            default:
                return false
        }
    }
    
    func hasDayLessThanItem(i2:Item) -> Bool
    {
        switch day
        {
            case Day.Sunday:
                return true
            case Day.Monday:
                return i2.day != Day.Sunday
            case Day.Tuesday:
                return i2.day != Day.Sunday && i2.day != Day.Monday
            case Day.Wednesday:
                return i2.day != Day.Sunday && i2.day != Day.Monday && i2.day != Day.Tuesday
            case Day.Thursday:
                return i2.day == Day.None || i2.day == Day.Saturday || i2.day == Day.Friday || i2.day == Day.Thursday
            case Day.Friday:
                return i2.day == Day.None || i2.day == Day.Saturday || i2.day == Day.Friday
            case Day.Saturday:
                return i2.day == Day.None || i2.day == Day.Saturday
            case Day.None:
                return i2.day == Day.None
            default:
                return false
        }
    }
}
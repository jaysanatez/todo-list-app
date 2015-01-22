//
//  Enums.swift
//  ToDoList
//
//  Created by Jacob Sanchez on 12/21/14.
//  Copyright (c) 2014 JSanch. All rights reserved.

import Foundation

enum Status:Printable
{
    case Not_Started, In_Progress, Completed, Will_Not_Complete
    
    var description: String
        {
            switch self
            {
                case .Not_Started:          return "Not Started"
                case .In_Progress:          return "In Progress"
                case .Completed:            return "Completed"
                case .Will_Not_Complete:    return "Will Not Complete"
                default:                    return ""
            }
    }
}

enum Priority:Printable
{
    case Low, Medium, High
    
    var description: String
    {
        switch self
        {
            case .Low:      return "Low"
            case .Medium:   return "Medium"
            case .High:     return "High"
            default:        return ""
        }
    }
}

enum Day:Printable
{
    case Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, None
    
    var description: String
    {
        switch self
        {
            case .Sunday:       return "Sunday"
            case .Monday:       return "Monday"
            case .Tuesday:      return "Tuesday"
            case .Wednesday:    return "Wednesday"
            case .Thursday:     return "Thursday"
            case .Friday:       return "Friday"
            case .Saturday:     return "Saturday"
            case .None:         return "None"
            default:            return ""
        }
    }
}
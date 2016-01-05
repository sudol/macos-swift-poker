//
//  RoundViewController.swift
//  poker
//
//  Created by Paul Sudol on 1/5/16.
//  Copyright © 2016 Paul Sudol. All rights reserved.
//

import AppKit

class RoundViewController : NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    //MARK: NSTableViewDataSource
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
//        return game.rounds.count
        return 1
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView: NSTableCellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
        
        if tableColumn!.identifier == "roundId" {
            let roundId = row
//            cellView.textField!.stringValue = "Hand \(game.rounds[roundId].id)"
            
            return cellView
        }
        
        return cellView
    }
    
    //MARK: NSTableViewDelegate
    func tableViewSelectionDidChange(notification: NSNotification) {
//        showRound((notification.object?.selectedRow)!)
    }

}

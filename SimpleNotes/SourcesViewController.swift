//
//  SourcesViewController.swift
//  SimpleNotes
//
//  Created by Patrick Günthard on 11.12.19.
//  Copyright © 2019 Patrick Günthard. All rights reserved.
//

import Cocoa


class SourcesViewController: NSViewController {
    var sources:[Source] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}


extension SourcesViewController:NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return sources.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?{
        var result:NSTableCellView
        result  = tableView.makeView(withIdentifier: (tableColumn?.identifier)!, owner: self) as! NSTableCellView
        result.textField?.stringValue = sources[row].title
        return result
    }

}

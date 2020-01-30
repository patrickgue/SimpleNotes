//
//  NewNoteViewController.swift
//  SimpleNotes
//
//  Created by Patrick Günthard on 30.01.20.
//  Copyright © 2020 Patrick Günthard. All rights reserved.
//

import Cocoa


class NewNoteWindowController : NSViewController {
    weak var delegate:CreateNoteProtocol?

    @IBOutlet weak var newNoteTitle: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func createNote(_ sender: Any) {
        if(newNoteTitle.stringValue.count > 0) {
            delegate?.createNote(name: newNoteTitle.stringValue)
            newNoteTitle.stringValue = ""
            self.dismiss(sender)
        }
    }
}

protocol CreateNoteProtocol:class {
    func createNote(name:String)
}

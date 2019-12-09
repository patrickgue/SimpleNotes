//
//  WelcomeWindowController.swift
//  SimpleNotes
//
//  Created by Patrick Günthard on 09.12.19.
//  Copyright © 2019 Patrick Günthard. All rights reserved.
//

import Cocoa

class WelcomeViewController:NSViewController {
    @IBOutlet weak var pathView: NSPathControl!
    @IBOutlet weak var closeWelcomeButton: NSButton!

    let panel = NSOpenPanel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        if let storage = NSUserDefaultsController().defaults.string(forKey: "storage.location") {
            pathView.url = URL(fileURLWithPath: storage)
        }
        
    }
    
    @IBAction func selectPathAction(_ sender: Any) {
        if panel.runModal() == .OK {
            pathView.url=panel.url
            NSUserDefaultsController().defaults.set(panel.url?.path, forKey: "storage.location")
            closeWelcomeButton.isEnabled = true
        }
        
    }
    @IBAction func closeWelcome(_ sender: Any) {
        for window in NSApplication.shared.windows {
            if window.identifier?.rawValue == "mainWindow" {
                window.setIsVisible(true)
                (window.contentViewController as! ViewController).setFont()
                (window.contentViewController as! ViewController).refreshNoteList()
                (window.contentViewController as! ViewController).search(search: "")
            }
            else if window.identifier?.rawValue == "welcomeWindow" {
                window.setIsVisible(false)
            }
        }
    }
}



//
//  ViewController.swift
//  SimpleNotes
//
//  Created by Patrick Günthard on 02.12.19.
//  Copyright © 2019 Patrick Günthard. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var notesRaw:[Note] = []
    var notes:[Note] = []
    var fontSize:CGFloat = 14
    var fontStyle:String = "Monospaced"
    
    var newNoteView:NewNoteWindowController!
    var previewPopover:NSPopover!
    
    @IBOutlet weak var notesCount: NSTextField!
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var textView: MDTextView!
    @IBOutlet weak var selectNoteLabel: NSTextField!
    @IBOutlet weak var newNoteButton: NSButton!
    @IBOutlet weak var searchField: NSTextField!
    @IBOutlet weak var menuSplitView: NSSplitView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        

        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.textView.delegate = self
        self.searchField.delegate = self
        
        
//        self.menuSplitView.setPosition(200.0, ofDividerAt: 0)
        
        newNoteView = self.storyboard?.instantiateController(withIdentifier: "NewNoteView") as? NewNoteWindowController
        newNoteView.delegate = self
        var previewView = self.storyboard?.instantiateController(withIdentifier: "PreviewView") as? PreviewViewController
        //self.menuSplitView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[view(>=140,<=220)]", options: .alignAllLeading, metrics: nil, views:))
        self.view.addConstraint(NSLayoutConstraint(item: menuSplitView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0))
        previewPopover = NSPopover()
        previewPopover.contentViewController = previewView
                
        if NSUserDefaultsController().defaults.string(forKey: "storage.location") != nil {
            setFont()
            refreshNoteList()
            search(search: "")
        }
        else {
            for window in NSApplication.shared.windows {
                if window.identifier?.rawValue == "mainWindow" {
                    window.setIsVisible(false)
                }
            }

            let welcomeWindow = storyboard?.instantiateController(withIdentifier: "welcomeWindowController") as? NSWindowController
            welcomeWindow?.window?.display()
            welcomeWindow?.window?.setIsVisible(true)
            welcomeWindow?.window?.orderFrontRegardless()
        }


        
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    public func newNote(title:String) -> Void {
        notesRaw.append(Note(path: NSUserDefaultsController().defaults.string(forKey: "storage.location")! + "/"+title+".md", text: "# " + title))
        
        self.tableView.reloadData()
        search(search: "")
        
    }
    
    @IBAction func zoomTextSize(_ sender: NSMagnificationGestureRecognizer) {
        fontSize += (sender.magnification)
        setFont()
    }
    public func search(search:String) -> Void {
        notes = []
        for note in notesRaw {
            print(note.title + ", " + search)
            if search == "" || note.title.contains(search) || note.text.contains(search) {
                notes.append(note)
            }
        }
        notes.sort(by: { (a:Note, b:Note) -> Bool in
            return a.title < b.title
        })
        notesCount.stringValue = String(notes.count)
        self.tableView.reloadData()
    }
    
    public func refreshNoteList() {
        notesRaw = []
        let directoryContents:[URL] = try! FileManager.default.contentsOfDirectory(at:  URL(fileURLWithPath: NSUserDefaultsController().defaults.string(forKey: "storage.location")!), includingPropertiesForKeys: nil)
        print(directoryContents)

        // if you want to filter the directory contents you can do like this:
        let noteFiles = directoryContents.filter{ $0.pathExtension == "md" }
        print("md urls:",noteFiles)
        
        for noteFile:URL in noteFiles {
            notesRaw.append(Note(path:noteFile.path))
        }
        
        search(search: "")

    }

    public func closeNote() {
        textView.isEditable = false
        textView.string = ""
        selectNoteLabel.isHidden = false
    }
    
    @IBAction func selectNote(_ sender: Any) {
        if tableView.selectedRow >= 0 {
            textView.resetHighliting()
            textView.string = notes[tableView.selectedRow].text
            textView.isEditable = true
            selectNoteLabel.isHidden = true
            setFont()
            textView.setHighlight()
        }
    }
    
    
    @IBAction func openNewNoteWindow(_ sender: NSButton) {
        present(newNoteView, asPopoverRelativeTo: (newNoteButton.bounds), of: newNoteButton, preferredEdge: NSRectEdge.minX, behavior: NSPopover.Behavior.transient)
    }
    
    @IBAction func closeNoteMenuBarClicked(_ sender: Any) {
        closeNote()
    }

    @IBAction func saveNowMenuBarClicked(_ sender: Any) {
        notes[tableView.selectedRow].saveFile()
    }
    @IBAction func deleteNote(_ sender: Any) {
        closeNote()
        notes[tableView.selectedRow].deleteFile()
        refreshNoteList()
    }
    
    @IBAction func refreshList(_ sender: Any) {
        closeNote()
        refreshNoteList()
    }
    @IBAction func fontLarger(_ sender: Any) {
        fontSize += 1
        setFont()
    }
    @IBAction func fontSmaller(_ sender: Any) {
        if fontSize > 5 {
            fontSize -= 1
        }
        setFont()
    }
    @IBAction func fontSizeReset(_ sender: Any) {
        fontSize = 14
        setFont()
    }
    
    @IBAction func textStyleChanged(_ sender: NSPopUpButton) {
        fontStyle = sender.selectedItem?.title ?? "Monospaced"
        setFont()
    }
    
    func setFont() {
        if fontStyle == "Monospaced" {
            textView.font = .monospacedSystemFont(ofSize: fontSize, weight: .regular)
        }
        else if fontStyle == "Sans Serif" {
            textView.font = .systemFont(ofSize: fontSize)
        }
        else {
            textView.font = NSFont(name: "Georgia", size: fontSize)
        }
        textView.setHighlight()
    }
    
    @IBAction func setFontMono(_ sender: Any) {
        fontStyle = "Monospaced";
        setFont()
    }
    
    @IBAction func setFontSans(_ sender: Any) {
        fontStyle = "Sans Serif";
        setFont()
    }
    
    @IBAction func setFontSerif(_ sender: Any) {
        fontStyle = "Serif";
        setFont()
    }
    
        
    @IBAction func showPreview(_ sender: NSButton) {
        previewPopover.show(relativeTo: sender.bounds, of: self.view, preferredEdge: .maxX)

        previewPopover.behavior = .applicationDefined;

    }
    
    
    

}

extension ViewController:NSTableViewDataSource, NSTableViewDelegate, NSSplitViewDelegate{
    func numberOfRows(in tableView: NSTableView) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?{
        var result:NSTableCellView
        result  = tableView.makeView(withIdentifier: (tableColumn?.identifier)!, owner: self) as! NSTableCellView
        result.textField?.stringValue = notes[row].title
        return result
    }
    
}


extension ViewController:NSTextViewDelegate, NSTextFieldDelegate {
    func textDidChange(_ notification: Notification) {
        setFont()
        notes[tableView.selectedRow].text = textView.string
        notes[tableView.selectedRow].updateTitle()
        notes[tableView.selectedRow].saveFile()
    }
    
    func controlTextDidChange(_ obj: Notification) {
        closeNote();
        search(search: searchField.stringValue)
    }


    
}


extension ViewController:CreateNoteProtocol {
    func createNote(name: String) {
        newNote(title: name)
    }
}

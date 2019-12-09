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
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var selectNoteLabel: NSTextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.textView.delegate = self
        
        
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

    public func newNote() -> Void {
        notesRaw.append(Note(path: "/Users/patrick/ownCloud/Notes/Untitled.md"))
        
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
            resetHighliting()
            textView.string = notes[tableView.selectedRow].text
            textView.isEditable = true
            selectNoteLabel.isHidden = true
            setFont()
            setHighlight()
        }
    }
    
    
    @IBAction func newNoteMenuBarClicked(_ sender: Any) {
        newNote()
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
        setHighlight()
    }
    
    func setHighlight() {
        //let fullRange = NSRange(location: 0, length: textView.textStorage!.length)
        for paragraph in textView.textStorage!.paragraphs {
            let paragraphRange = NSRange(location: 0, length: paragraph.length)
            if paragraph.string.hasPrefix("# ") {
                paragraph.addAttributes([.foregroundColor:NSColor.selectedContentBackgroundColor, .font:NSFont.systemFont(ofSize: 24, weight: NSFont.Weight.black)], range: paragraphRange)
            }
            else if paragraph.string.hasPrefix("## ") {
                paragraph.addAttributes([.font:NSFont.systemFont(ofSize: 20, weight: NSFont.Weight.black)], range: paragraphRange)
            }
            else if paragraph.string.hasPrefix("### ") {
                paragraph.addAttributes([.font:NSFont.systemFont(ofSize: 16, weight: NSFont.Weight.bold)], range: paragraphRange)
            }
            else if paragraph.string.hasPrefix("#### ") {
                paragraph.addAttributes([.font:NSFont.systemFont(ofSize: 14, weight: NSFont.Weight.bold)], range: paragraphRange)
            }
            
            
        }
        
        //textView.textStorage?.addAttributes([.foregroundColor:NSColor.red], range: NSRange(location: 0, length: 10))
        //let italicsPattern = try? NSRegularExpression(pattern: "\\*[A-z0-9,.:; !-=\"'<>{}]*\\*[^\\*]", options: .useUnixLineSeparators)
        //let boldPattern = try? NSRegularExpression(pattern: "\\*\\*[A-z0-9,.:; !-=\"'<>{}]*\\*\\*", options: .ignoreMetacharacters)
                    
        /*            for match:NSTextCheckingResult in (boldPattern?.matches(in: paragraph.string, options: .withTransparentBounds, range: paragraphRange))! {
                        
                        if let font = paragraph.attribute(NSAttributedString.Key.font, at: match.range.location, effectiveRange: nil) as? NSFont {
                            paragraph.addAttributes([.font:NSFont(name: font.familyName! + "-Bold", size: font.pointSize)], range: match.range)
                        }
                    }*/
                    
        /*for match:NSTextCheckingResult in (italicsPattern?.matches(in: textView.textStorage!.string, options: .withTransparentBounds, range: fullRange))! {
            textView.textStorage.sub
            textView.textStorage!.addAttributes([NSAttributedString.Key.obliqueness:0.4], range: match.range)
        }*/
    }
    
    
    func resetHighliting() {
        textView.textStorage?.setAttributes([.foregroundColor:NSColor.textColor], range: NSRange(location: 0, length: textView.textStorage!.length))
    }
    

}

extension ViewController:NSTableViewDataSource, NSTableViewDelegate{
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


extension ViewController:NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        resetHighliting()
        setFont()
        setHighlight()
        notes[tableView.selectedRow].text = textView.string
        notes[tableView.selectedRow].updateTitle()
        notes[tableView.selectedRow].saveFile()
    }
    


    
}

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
    @IBOutlet weak var notesCount: NSTextField!
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var selectNoteLabel: NSTextField!
    @IBOutlet weak var newNoteButton: NSButton!
    @IBOutlet weak var searchField: NSTextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.textView.delegate = self
        self.searchField.delegate = self
        
        
        newNoteView = self.storyboard?.instantiateController(withIdentifier: "NewNoteView") as? NewNoteWindowController
        newNoteView.delegate = self
        
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
            resetHighliting()
            textView.string = notes[tableView.selectedRow].text
            textView.isEditable = true
            selectNoteLabel.isHidden = true
            setFont()
            setHighlight()
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
        setHighlight()
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
    
    func setHighlight() {
        let fullRange = NSRange(location: 0, length: textView.textStorage!.length)
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
            
            /*let italicsPattern = try? NSRegularExpression(pattern: " \\*[A-z0-9,.:; !-=\"'<>{}]*\\*[^\\*]", options: .useUnixLineSeparators)
            let boldPattern = try? NSRegularExpression(pattern: "\\*\\*[A-z0-9,.:; !-=\"'<>{}]*\\*\\*", options: .useUnixLineSeparators)
                        
            for match:NSTextCheckingResult in (boldPattern?.matches(in: paragraph.string, options: .withoutAnchoringBounds, range: paragraphRange))! {
                            
                if let font = paragraph.font {
                    
                    NSFontManager.shared.convertWeight(true, of: font)
                    paragraph.addAttributes([.font:  NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask) ], range: match.range)
                }
            }
                        
            for match:NSTextCheckingResult in (italicsPattern?.matches(in: textView.textStorage!.string, options: .withoutAnchoringBounds, range: fullRange))! {
                textView.textStorage!.addAttributes([NSAttributedString.Key.obliqueness:0.2], range: match.range)
            }
            */
        }
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


extension ViewController:NSTextViewDelegate, NSTextFieldDelegate {
    func textDidChange(_ notification: Notification) {
        resetHighliting()
        setFont()
        setHighlight()
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

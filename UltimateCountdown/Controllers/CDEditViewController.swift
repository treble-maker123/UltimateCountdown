//
//  CDEditViewController.swift
//  UltimateCountdown
//
//  Created by Ziqiang Guan on 11/5/17.
//  Copyright © 2017 Ziqiang Guan. All rights reserved.
//

import Cocoa

class CDEditViewController: NSViewController {
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var datePicker: NSDatePicker!
    @IBOutlet weak var currentChar: NSTextField!
    @IBOutlet weak var maxChar: NSTextField!
    @IBOutlet weak var confirmBtn: NSButton!
    
    var isAdding: Bool = true
    var object: NSManagedObject?
    
    
    private let _manager:CDItemsManager = CDItemsManager.shared
    private let _maxLength: Int = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isAdding {
            self.textField.placeholderString = "Limited to \(self._maxLength) characters."
            self.datePicker.minDate = Date()
            self.currentChar.stringValue = String(self.textField.stringValue.count)
            self.maxChar.stringValue = String(self._maxLength)
            self.confirmBtn.stringValue = "Add"
        } else {
            self.confirmBtn.stringValue = "Update"
        }
    }
    
    @IBAction func btnPressed(_ sender: Any) {
        if isAdding {
            let name: String = self.textField.stringValue
            let endDate: Date = self.datePicker.dateValue
            self._manager.addItem(name: name, endDate: endDate)
            self.dismissViewController(self)
        } else {
            
        }
    }
}

extension CDEditViewController: NSTextFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        let field: NSTextField = obj.object as! NSTextField
        
        // setting character limit
        if field.stringValue.count > self._maxLength {
            let index = field.stringValue.index(field.stringValue.startIndex, offsetBy: self._maxLength)
            field.stringValue = String(field.stringValue[..<index])
        }
        // updating character count
        self.currentChar.stringValue = String(field.stringValue.count)
    }
}

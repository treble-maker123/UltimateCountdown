//
//  CDDigitView.swift
//  UltimateCountdown
//
//  Created by Ziqiang Guan on 11/5/17.
//  Copyright © 2017 Ziqiang Guan. All rights reserved.
//

import Cocoa

class CDDigitView: NSView {
    // MARK: - Public properties
    @IBOutlet var contentView: CDDigitView!
    @IBOutlet weak var firstField: NSTextField!
    @IBOutlet weak var secondField: NSTextField!
    
    /*
     Returns the digit that is currently being displayed by the DigitView
    */
    var digit: Int {
        get {
            return self._showingFirst ? self._firstDigit : self._secondDigit
        }
        set (newDigit) {
            self._showingFirst = true
            self.firstField.alphaValue = CGFloat(1.0)
            self.firstField.setFrameOrigin(self._showCoord)
            self.secondField.alphaValue = CGFloat(0.0)
            self.secondField.setFrameOrigin(self._hideCoord)
            
            self._firstDigit = newDigit
            self._secondDigit = (newDigit + 1) % (self.range.max + 1) + self.range.min
        }
    }
    
    /**
     A tuple of (min, max) values this DigitView will loop through before it goes around. Defaults to (0, 9).
     
     Decrement from 0 will give 9 if range is set to (0, 9)
     */
    private var _range: DigitRange = DigitRange()
    var range: DigitRange {
        get{
            if self.possibleRange.count > 0 && self.previous != nil {
                // if there are other possible ranges, return the first one with a condition that evalutates to true
                let previousDigit: Int = self.previous!.digit
                for range in self.possibleRange {
                    if(range.0(previousDigit)) {
                        return range.1
                    }
                }
                return self._range
            } else {
                return self._range
            }
        } set (newValue) {
            self._range = newValue
        }
    }
    /**
     An array of (condition, range) that contains a set of possible ranges aside from the default "_range".
    */
    var possibleRange: [((_ previousDigit: Int) -> Bool, DigitRange)] = []
    

    /**
     A reference to the digit before this.
    */
    var previous: CDDigitView?
    
    
    // MARK: - Private properties
    
    // (X, Y) coordinates of where text fields should be at various stages
    private let _showCoord: NSPoint = NSPoint(x: 0, y: 0) // showing
    private let _hideCoord: NSPoint = NSPoint(x: 0, y: 42) // getting ready to show
    
    private var _firstDigit: Int {
        get {
            return Int(self.firstField.stringValue)!
        }
        set (newValue){
            self.firstField.stringValue = String(newValue)
        }
    }
    private var _secondDigit: Int {
        get {
            return Int(self.secondField.stringValue)!
        }
        set (newValue) {
            self.secondField.stringValue = String(newValue)
        }
    }
    
    private var _showingFirst: Bool = true
    
    // MARK: - Public functions
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initSubview()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initSubview()
    }
    
    /**
     Decrease the digit by one with animation.
     
     - returns:
        Whether or not the decrement action was successful. It could have failed due to value being too low to be decremented.
    */
    func decrement() -> Bool {
        var successful = true
        
        // If this digit is at min, it will decrement the previous digit by 1. If it fails to do that, this decrement attempt will be considered failed.
        if self.digit == self.range.min {
            if (self.previous == nil) {
                return false
            } else {
                successful = self.previous!.decrement()
            }
        }
        
        if successful {
            self._showingFirst ?
                self.animatedDecrement(toShow: self.secondField, toHide: self.firstField) :
                self.animatedDecrement(toShow: self.firstField, toHide: self.secondField)
            self._showingFirst = !self._showingFirst
        }
        
        return successful
    }
    
    
    // MARK: - Private functions
    
    /**
     Calculates the new value to be shown and animates the display. Hides the old value.
     
     - parameters:
        - show: The text field that is currently hidden but needs to be shown
        - hide: The text field that is currently shown but needs to be hidden
     
     - returns:
        Whether or not the decrement action was successful. It could have failed due to value being too low to be decremented.
    */
    private func animatedDecrement(toShow show: NSTextField, toHide hide: NSTextField) {
        // update the value to be shown
        var showValue = Int(show.stringValue)!
        if !(showValue > 1) { showValue += self.range.max + 1 }
        showValue -= 2
        show.stringValue = String(showValue)

        show.alphaValue = CGFloat(1.0)

        // Animation
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = 0.5
        hide.animator().setFrameOrigin(self._hideCoord)
        show.animator().setFrameOrigin(self._showCoord)
        NSAnimationContext.endGrouping()

        hide.alphaValue = CGFloat(0.0)
    }
    
    private func initSubview() {
        // initializes the Xib file and adding it as a subview
        if self.subviews.count == 0 {
            if (!Bundle.main.loadNibNamed(NSNib.Name(rawValue: "CDDigitView"), owner: self, topLevelObjects: nil)) {
                print("Failed to load CDDigitView")
                return
            }
            self.addSubview(self.contentView)
            contentView.frame = self.bounds
            
            // resets everything
            self.digit = 0
        }
    }
}

struct DigitRange {
    var min = 0
    var max = 9
}

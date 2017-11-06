//
//  CDCollectionViewItem.swift
//  UltimateCountdown
//
//  Created by Ziqiang Guan on 11/5/17.
//  Copyright © 2017 Ziqiang Guan. All rights reserved.
//

import Cocoa

class CDCollectionViewItem: NSCollectionViewItem {
    @IBOutlet weak var thDay: CDDigitView! //thousandth digit
    @IBOutlet weak var hDay: CDDigitView! //hundredth digit
    @IBOutlet weak var tDay: CDDigitView! // tenth digit
    @IBOutlet weak var dDay: CDDigitView! // digit
    
    @IBOutlet weak var tHr: CDDigitView! // tenth digit
    @IBOutlet weak var dHr: CDDigitView! // digit
    
    @IBOutlet weak var tMin: CDDigitView! // tenth digit
    @IBOutlet weak var dMin: CDDigitView! // digit
    
    @IBOutlet weak var tSec: CDDigitView! // tenth digit
    @IBOutlet weak var dSec: CDDigitView! // digit
    
    @IBOutlet weak var nameField: NSTextField!
    
    @IBOutlet var contentView: NSView!
    
    weak var currentListVC: CDListViewController?
    
    var item: NSManagedObject? {
        get { return self._item }
    }
    
    // MARK: - Private properties
    
    private let _updateItemSegueId = NSStoryboardSegue.Identifier(rawValue: "updateItem")
    
    private var _item: NSManagedObject?
    private var _timer: Timer?
    private var _displayTime: DisplayTime = DisplayTime()
    private var _manager: CDItemsManager = CDItemsManager.shared
    
    // MARK: - Public functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // link up all of the digits and setting their range
        self.dSec.previous = self.tSec
        self.tSec.previous = self.dMin
        self.tSec.range = DigitRange(min: 0, max: 5)
        
        self.dMin.previous = self.tMin
        self.tMin.previous = self.dHr
        self.tMin.range = DigitRange(min: 0, max: 5)
        
        self.dHr.previous = self.tHr
        self.tHr.previous = self.dDay
        self.tHr.range = DigitRange(min: 0, max: 2)
        
        self.dDay.previous = self.tDay
        self.tDay.previous = self.hDay
        self.hDay.previous = self.thDay

        /*
         The digit of hour should be (0, 3) if the tenth number is 2. Hour 23, Hour 22etc.
         
         Hour 25 is not a valid hour, whereas hour 15 is. And hour 24 = day 1
        */
        self.dHr.possibleRange.append(({
            (previousDigit) in
            return previousDigit == 2
        }, DigitRange(min: 0, max: 3)))
    }
    
    /**
     Set this CollectionViewItem to a NSManagedObject of type CountdownItem. The properties from the NSManagedObject will be read and displayed in this view. A timer will be triggered as well.
     */
    func setItem(item: NSManagedObject, currentVC: CDListViewController) {
        self._item = item
        self.currentListVC = currentVC
        
        // setting name
        guard let name: String = item.value(forKeyPath: "name") as? String else {
            print("Failed to retrieve name from NSManagedObject")
            return
        }
        self.nameField.stringValue = name
        
        // setting count down
        guard let date: Date = item.value(forKeyPath: "endDate") as? Date else {
            print("Failed to retrieve endDate from NSManagedObject")
            return
        }
        self._displayTime = DisplayTime(interval: Int(date.timeIntervalSinceNow))
        self.updateViewTime(time: self._displayTime)
        self.stopTimer() // deinit isn't called when reloadData() is called on NSCollectionView, so have to reset timer here to fix strange behavior
        self.startTimer()
    }
    
    func startTimer() {
        if self._displayTime.interval < 1 { return }
        
        self._timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {(timer: Timer) in
            self.decrement()
        })
        
        // Add the timer to a different run loop so user interaction doesn't stop the countdown
        RunLoop.main.add(self._timer!, forMode: RunLoopMode.commonModes)
    }
    
    func stopTimer() {
        if self._timer != nil { self._timer!.invalidate() }
    }
    
    // MARK: - IBActions
    
    @IBAction func editBtnPressed(_ sender: Any) {
        self.currentListVC?.performSegue(withIdentifier: self._updateItemSegueId, sender: self)
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        let alert: NSAlert = NSAlert()
        alert.messageText = "Deleting Event or Task"
        alert.informativeText = "Are you sure you would like to delete \"\(self.nameField.stringValue)\"?"
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .warning
        
        alert.beginSheetModal(for: NSApp.windows[0], completionHandler: {
            (response: NSApplication.ModalResponse) in
            if response == NSApplication.ModalResponse.alertFirstButtonReturn {
                self._manager.removeItem(object: self._item!)
            }
        })
    }
    
    // MARK: - Private functions
    
    /**
     Reduce the countdowm timer by one second.
     */
    private func decrement() {
        _ = self.dSec.decrement()
    }
    
    /**
     Takes in a DisplayTime object and update each of the DigitView.
    */
    private func updateViewTime(time: DisplayTime) {
        /*
         Returns the nth digit
         
         getDigit(12345, 100) -> 3
        */
        func getDigit(digit: Int, mod: Int) -> Int { return (digit - digit % mod) / mod % 10 }
        
        self.thDay.digit = getDigit(digit: time.day, mod: 1000)
        self.hDay.digit = getDigit(digit: time.day, mod: 100)
        self.tDay.digit = getDigit(digit: time.day, mod: 10)
        self.dDay.digit = getDigit(digit: time.day, mod: 1)
        
        self.tHr.digit = getDigit(digit: time.hour, mod: 10)
        self.dHr.digit = getDigit(digit: time.hour, mod: 1)
        
        self.tMin.digit = getDigit(digit: time.min, mod: 10)
        self.dMin.digit = getDigit(digit: time.min, mod: 1)
        
        self.tSec.digit = getDigit(digit: time.sec, mod: 10)
        self.dSec.digit = getDigit(digit: time.sec, mod: 1)
    }
    
    // MARK: - Nested classes
    
    private class DisplayTime {
        var day: Int = 0
        var hour: Int = 0
        var min: Int = 0
        var sec: Int = 0
        var interval: Int {
            get {
                return _interval
            } set (newValue) {
                self._interval = newValue
                
                let minFactor = 60 // 60 seconds in 1 minute
                let hrFactor = minFactor * minFactor // 60*60 seconds in 1 hour
                let dayFactor = hrFactor * 24 // 3600 * 24 seconds in 1 day
                
                /**
                 Calculates how many days/hours/mins/secs in the interval, then subtracts that many seconds from the interval.
                 
                 - returns:
                 A tuple (number of days/hours/mins/secs, leftover seconds in intvl)
                 */
                func calculateTime(intvl: Int, factor: Int) -> (Int, Int) {
                    let seconds = intvl - intvl % factor
                    let num = Int(seconds / factor)
                    return (num, intvl - seconds)
                }
                
                let days = calculateTime(intvl: newValue, factor: dayFactor)
                self.day = days.0
                
                let hours = calculateTime(intvl: days.1, factor: hrFactor)
                self.hour = hours.0
                
                let minutes = calculateTime(intvl: hours.1, factor: minFactor)
                self.min = minutes.0
                
                self.sec = minutes.1
            }
        }
        
        private var _interval: Int = 0
        
        init(interval: Int = 0) {
            if (interval < 1) { return }
            self.interval = interval
        }
        
        func printTime() {
            print("Setting. interval to DisplayTime")
            print("Interval is \(self.interval)")
            print("\tDays \(self.day)")
            print("\tHours \(self.hour)")
            print("\tMins \(self.min)")
            print("\tSec \(self.sec)")
        }
    }
    
    deinit {
        self.stopTimer()
    }
}

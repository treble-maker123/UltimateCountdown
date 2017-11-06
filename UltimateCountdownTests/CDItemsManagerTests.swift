//
//  CDItemsManagerTests.swift
//  UltimateCountdownTests
//
//  Created by Ziqiang Guan on 11/5/17.
//  Copyright © 2017 Ziqiang Guan. All rights reserved.
//

import XCTest
@testable import UltimateCountdown

class CDItemsManagerTests: XCTestCase {

    var manager: CDItemsManager = CDItemsManager.shared
    
    let maxItems = 10
    
    override func setUp() {
        super.setUp()
        self.manager.purgeItems()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        self.manager.purgeItems()
    }
    
    func testManagerInit() {
        XCTAssertNotNil(self.manager)
        XCTAssertNotNil(self.manager.persistent)
    }
    
    func testAddItem() {
        for i in [Int](0...self.maxItems) {
            XCTAssertEqual(self.manager.items.count, i)
            XCTAssertTrue(self.manager.addItem(name: "Test", endDate: Date()))
            XCTAssertEqual(self.manager.items.count, i+1)
        }
        
        // making sure the data store is in agreement with manager.items
        let storeItems = self.fetchItemsFromDataStore()!
        XCTAssertEqual(self.manager.items.count, storeItems.count)
    }
    
    func testRemoveItem() {
        for _ in [Int](1...self.maxItems) {
            XCTAssertTrue(self.manager.addItem(name: "Test", endDate: Date()))
        }
        XCTAssertEqual(self.manager.items.count, self.maxItems)
        self.manager.removeItem(object: self.manager.items.last!)
        XCTAssertEqual(self.manager.items.count, self.maxItems - 1)
        
        let storeItems = self.fetchItemsFromDataStore()!
        XCTAssertEqual(self.manager.items.count, storeItems.count)
    }
    
    func testUpdateItemName() {
        let updatedName = "Updated"
        
        for _ in [Int](1...self.maxItems) {
            XCTAssertTrue(self.manager.addItem(name: "Test", endDate: Date()))
        }
        XCTAssertEqual(self.manager.items.count, self.maxItems)
        self.manager.updateItem(name: updatedName, object: self.manager.items.last!)
        
        var isInItems = false
        for item in self.manager.items {
            let name = item.value(forKey: "name") as? String
            if(name == updatedName) { isInItems = true }
        }
        XCTAssertTrue(isInItems)
        
        let storeItems = self.fetchItemsFromDataStore()!
        var isInStore = false
        for item in storeItems {
            let name = item.value(forKey: "name") as? String
            if name == updatedName { isInStore = true }
        }
        XCTAssertTrue(isInStore)
    }
    
    func testUpdateItemEndDate() {
        let startDate = Date()
        let updatedDate = Date(timeIntervalSinceNow: 3600)
        
        for _ in [Int](1...self.maxItems) {
            XCTAssertTrue(self.manager.addItem(name: "Test", endDate: startDate))
        }
        XCTAssertEqual(self.manager.items.count, self.maxItems)
        self.manager.updateItem(endDate: updatedDate, object: self.manager.items.last!)
        
        var isInItems = false
        for item in self.manager.items {
            let endDate = item.value(forKey: "endDate") as? Date
            if endDate != startDate { isInItems = true }
        }
        XCTAssertTrue(isInItems)
        
        let storeItems = self.fetchItemsFromDataStore()!
        var isInStore = false
        for item in storeItems {
            let endDate = item.value(forKey: "endDate") as? Date
            if endDate != startDate { isInStore = true }
        }
        XCTAssertTrue(isInStore)
    }
    
    func testPurgeItems() {
        for _ in [Int](1...self.maxItems) {
            XCTAssertTrue(self.manager.addItem(name: "Test", endDate: Date()))
        }
        XCTAssertEqual(self.manager.items.count, self.maxItems)
        XCTAssertTrue(self.manager.purgeItems())
        XCTAssertEqual(self.manager.items.count, 0)
        
        // making sure the data store is in agreement with manager.items
        let storeItems = self.fetchItemsFromDataStore()!
        XCTAssertEqual(self.manager.items.count, storeItems.count)
    }
    
    func testSyncItems() {
        for _ in [Int](1...self.maxItems) {
            XCTAssertTrue(self.manager.addItem(name: "Test", endDate: Date()))
        }
        XCTAssertEqual(self.manager.items.count, self.maxItems)
        
        // removing items from items array
        let numToRemove = 2
        for _ in [Int](1...numToRemove) {
            _ = self.manager.items.popLast()
        }
        
        let storeItems = self.fetchItemsFromDataStore()
        XCTAssertNotEqual(self.manager.items.count, storeItems?.count)
        
        self.manager.syncItems()
        XCTAssertEqual(self.manager.items.count, storeItems?.count)
        XCTAssertEqual(self.manager.items.count, self.maxItems)
    }
    
    /**
     Fetches and returns an array of CountdownItem objects from the local store
     */
    private func fetchItemsFromDataStore() -> [NSManagedObject]? {
        let context = self.manager.persistent.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "CountdownItem")
        do {
            return try context.fetch(request)
        } catch let error as NSError {
            print("Could not fetch countdown items. \(error), \(error.userInfo)")
            return nil
        }
    }

}

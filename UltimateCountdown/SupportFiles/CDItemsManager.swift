//
//  CDItemsManager.swift
//  UltimateCountdown
//
//  Created by Ziqiang Guan on 11/5/17.
//  Copyright © 2017 Ziqiang Guan. All rights reserved.
//

import Cocoa

class CDItemsManager {
    // MARK: - Public properties
    var persistent: NSPersistentContainer!
    var items: [NSManagedObject] = []
    
    var onItemsChanged: (_ action: ManagerAction) -> Void = {(action) in }
    var onItemAdded: (_ item: NSManagedObject, _ index: Int) -> Void = {(item, index) in }
    var onItemRemoved: (_ index: Int) -> Void = {(index) in }
    var onItemUpdated: (_ updatedItem: NSManagedObject) -> Void = {(item) in }
    var onItemsPurged: () -> Void = {() in }
    
    static let shared = CDItemsManager()
    
    // MARK: - Private properties
    
    // MARK: - Public functions
    
    /**
     Adds an item to the local data store.
     
     - returns:
     Bool   Whether the action was successful
     */
    @discardableResult func addItem(name: String, endDate: Date) -> Bool {
        let context = self.persistent.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CountdownItem", in: context)!
        let item = NSManagedObject(entity: entity, insertInto: context)
        item.setValue(name, forKeyPath: "name")
        item.setValue(endDate, forKeyPath: "endDate")
        
        do {
            try context.save()
            self.items.append(item)
            self.onItemAdded(item, self.items.index(of: item)!)
            self.onItemsChanged(.add)
            return true
        } catch let error as NSError {
            print("Could not save countdown items. \(error), \(error.userInfo)")
            return false
        }
    }
    
    /**
     Remove an item from the local data store and the "items" array.
    */
    @discardableResult func removeItem(object: NSManagedObject) -> Bool {
        let context = self.persistent.viewContext
        context.delete(object)
        do {
            try context.save()
            let index: Int = self.items.index(of: object)!
            self.items.remove(at: index)
            self.onItemRemoved(index)
            self.onItemsChanged(.remove)
            return true
        } catch let error as NSError {
            print("Could not remove item. \(error), \(error.userInfo)")
            return false
        }
    }
    
    /**
     Update the name of an item.
    */
    @discardableResult func updateItem(name: String, object: NSManagedObject) -> Bool {
        let context = self.persistent.viewContext
        object.setValue(name, forKey: "name")
        do {
            try context.save()
            self.onItemUpdated(object)
            self.onItemsChanged(.update)
            return true
        } catch let error as NSError {
            print("Could not update item. \(error), \(error.userInfo)")
            return false
        }
    }
    
    /**
     Update the end date of an item.
    */
    @discardableResult func updateItem(endDate: Date, object: NSManagedObject) -> Bool {
        let context = self.persistent.viewContext
        object.setValue(endDate, forKey: "endDate")
        do {
            try context.save()
            self.onItemUpdated(object)
            self.onItemsChanged(.update)
            return true
        } catch let error as NSError {
            print("Could not update item. \(error), \(error.userInfo)")
            return false
        }
    }
    
    /**
     Remove all items in the local data store as well as the items property.
     
     - returns:
     Bool   Wehther the action was successful
     */
    @discardableResult func purgeItems() -> Bool {
        let context = self.persistent.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "CountdownItem")
        do {
            let items = try context.fetch(request)
            for item in items {
                context.delete(item)
            }
            try context.save()
            self.onItemsPurged()
            self.onItemsChanged(.purge)
            self.items = []
            return true
        } catch let error as NSError {
            print("Could not fetch items. \(error), \(error.userInfo)")
            return false
        }
    }
    
    /**
     Fetch all of the data from the local data store into the items array. Called when CountdownItemManager is first initialized.
     */
    func syncItems() {
        let context = self.persistent.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "CountdownItem")
        do {
            self.items = try context.fetch(request)
            self.onItemsChanged(.sync)
        } catch let error as NSError {
            print("Could not fetch countdown items. \(error), \(error.userInfo)")
        }
    }
    
    /**
     Sort the items by endDate.
    */
    func sortItemsByEndDate(asc: Bool = true) {
        self.items = self.items.sorted {
            (first: NSManagedObject, second: NSManagedObject) in
            let firstEndDate = first.value(forKey: "endDate") as! Date
            let secondEndDate = second.value(forKey: "endDate") as! Date
            return asc ? firstEndDate < secondEndDate : firstEndDate > secondEndDate
        }
    }
    
    // MARK: - Private functions
    private init() {
        guard let delegate = NSApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        self.persistent = delegate.persistentContainer
        self.syncItems()
        self.sortItemsByEndDate()
    }
}

enum ManagerAction {
    case add, remove, update, purge, sync
}

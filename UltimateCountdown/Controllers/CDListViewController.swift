//
//  ViewController.swift
//  UltimateCountdown
//
//  Created by Ziqiang Guan on 11/5/17.
//  Copyright © 2017 Ziqiang Guan. All rights reserved.
//

import Cocoa

class CDListViewController: NSViewController {
    @IBOutlet weak var collection: NSCollectionView!
    
    private let _manager: CDItemsManager = CDItemsManager.shared
    private let _darkenColor: CGColor = CGColor(red: 224, green: 224, blue: 224, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self._manager.onItemAdded = {(item: NSManagedObject, index: Int) in
            let indexPath = IndexPath(item: index, section: 0)
            self.collection.performBatchUpdates({
                self.collection?.insertItems(at: [indexPath])
            }, completionHandler: nil)
        }
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destinationController
        
        if let editVC = destinationVC as? CDEditViewController {
            if (segue.identifier == NSStoryboardSegue.Identifier("addItem")) {
                editVC.isAdding = true
            }
        }
    }
}

/**
 Code to interface with the CollectionView to display all of the items
 */
extension CDListViewController: NSCollectionViewDataSource {
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return self._manager.items.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let identifier = NSUserInterfaceItemIdentifier("CDCollectionViewItem")
        let item = collectionView.makeItem(withIdentifier: identifier, for: indexPath)

        guard let countdownItem = item as? CDCollectionViewItem else { return item }
        countdownItem.setItem(item: self._manager.items[indexPath.item])
        
        return countdownItem
    }
}

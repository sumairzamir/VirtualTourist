//
//  DataController.swift
//  VirtualTourist
//
//  Created by Sumair Zamir on 13/04/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import CoreData

// Boilerplate code required to instantiate the DataController and persistant store.
class DataController {
    
    let persistantContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        return persistantContainer.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext!
    
    init(modelName: String) {
        persistantContainer = NSPersistentContainer(name: modelName)
    }
    
    func configureContext() {
        backgroundContext = persistantContainer.newBackgroundContext()
        
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completionHandler: (() -> Void)? = nil) {
        persistantContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.configureContext()
            completionHandler?()
        }
    }
    
}

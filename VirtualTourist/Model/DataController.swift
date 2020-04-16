//
//  DataController.swift
//  VirtualTourist
//
//  Created by Sumair Zamir on 13/04/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    
    // define the container
    
    let persistantContainer: NSPersistentContainer
    
    // define the context
    
    var viewContext: NSManagedObjectContext {
        
        return persistantContainer.viewContext
        
    }
    
    // Initialise the container
    
    init(modelName: String) {
        
        persistantContainer = NSPersistentContainer(name: modelName)
        
    }
    
    // Load the store
    
    func load(completionHandler: (() -> Void)? = nil) {
        
        persistantContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            
            completionHandler?()
            
        }
        
        
    }
    
    
    
}

extension DataController {
    
    // Add autosave code for later
    
}



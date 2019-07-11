//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Mohammed on 23/6/19.
//  Copyright © 2019 Mohammed. All rights reserved.
//

import Foundation
import CoreData

class DataController{
    static let sharedInstance = DataController()
    let persistentContainer = NSPersistentContainer(name: "VT")
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    func load(){
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
        }
    }
}

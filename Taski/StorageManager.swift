//
//  StorageManager.swift
//  Taski
//
//  Created by Виталий Гринчик on 20.05.23.
//

import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    private init() {}
    
    // MARK: - Core Data stack
    // "Точка входа" в БД
    var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "Taski")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

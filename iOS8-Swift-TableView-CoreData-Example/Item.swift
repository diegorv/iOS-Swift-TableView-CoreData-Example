//
//  Item.swift
//  iOS8-Swift-TableView-CoreData-Example
//
//  Created by Diego Rossini Vieira on 9/7/15.
//  https://github.com/diegorv/iOS-Swift-TableView-CoreData-Example
//

import Foundation
import CoreData

// MODEL
class Item: NSManagedObject {
	
	@NSManaged var name: String
	
	/// Function to initialize a new Item
	convenience init(name: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) {
		let entity = NSEntityDescription.entityForName("Item", inManagedObjectContext: managedObjectContext)!
		self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
		self.name = name
	}
	
	/// Function to get all CoreData values
	///
	/// :param: managedObjectContext CoreData Connection
	///
	class func fetchAll(managedObjectContext: NSManagedObjectContext) -> [Item] {
		let listagemCoreData             = NSFetchRequest(entityName: "Item")
		
		// Sort alphabetical by field "name"
		let orderByName                  = NSSortDescriptor(key: "name", ascending: true, selector: "caseInsensitiveCompare:")
		listagemCoreData.sortDescriptors = [orderByName]
		
		// Get items from CoreData
		return managedObjectContext.executeFetchRequest(listagemCoreData, error: nil) as? [Item] ?? []
	}
	
	/// Function to search item by name
	///
	/// :param: name Item name
	/// :param: managedObjectContext CoreData Connection
	///
	class func search(name: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> Item? {
		let fetchRequest       = NSFetchRequest(entityName: "Item")
		fetchRequest.predicate = NSPredicate(format: "name = %@", name)
		
		let result						 = managedObjectContext.executeFetchRequest(fetchRequest, error: nil) as? [Item]
		return result?.first
	}
	
	/// Function to check duplicate item
	///
	/// :param: name Item name
	/// :param: managedObjectContext CoreData Connection
	///
	class func checkDuplicate(name: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> Bool {
		return search(name, inManagedObjectContext: managedObjectContext) != nil
	}

	/// Function to delete a item
	///
	/// :param: managedObjectContext CoreData Connection
	///
	func destroy(managedObjectContext: NSManagedObjectContext) {
		managedObjectContext.deleteObject(self)
	}
	
	/// Function to save CoreData values
	///
	/// :param: managedObjectContext CoreData Connection
	///
	func save(managedObjectContext: NSManagedObjectContext) {
		var error: NSErrorPointer = nil
		
		if(managedObjectContext.save(error)) {
			if (error != nil) {
				println("Error on save: \(error.debugDescription)")
			}
		}
	}
}

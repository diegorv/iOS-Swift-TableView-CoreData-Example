//
//  Pessoas.swift
//  
//
//  Created by Diego Rossini Vieira on 8/26/15.
//
//

import Foundation
import CoreData

class Pessoas: NSManagedObject {

    @NSManaged var nome: String
	
	class func createInManagedObjectContext(moc: NSManagedObjectContext, nome: String) -> Pessoas {
		let newItem = NSEntityDescription.insertNewObjectForEntityForName("Pessoas", inManagedObjectContext: moc) as! Pessoas
		newItem.nome = nome
		
		return newItem
	}

}

//
//  Itens.swift
//  ListaCoreData
//
//  Created by Diego Rossini Vieira on 8/27/15.
//  Copyright (c) 2015 Diego Rossini Vieira. All rights reserved.
//

import Foundation
import CoreData

// MODEL para abstração dos dados
class Item: NSManagedObject {
	
	/// mapeamento do campo "nome" para String
	@NSManaged var nome: String
	
	/// Função para adicionar um item do CoreData de forma rápida
	///
	/// :param: objectContext Conexão com o CoreData
	/// :param: nome Nome para salvar
	///
	class func criaNovoObjeto(objectContext: NSManagedObjectContext, nome: String) -> Item {
		let newItem = NSEntityDescription.insertNewObjectForEntityForName("Item", inManagedObjectContext: objectContext) as! Item
		
		// fazendo o as! Item, não precisamos criar o objeto usando setValue, o que simplifica o processo
		newItem.nome = nome
		
		return newItem
	}
	
	/// Função para buscar todos os dados do CoreData
	///
	/// :param: managedObjectContext contexto a ser manipulado
	///
	class func buscarTodos(managedObjectContext: NSManagedObjectContext) -> [Item] {
		let listagemCoreData             = NSFetchRequest(entityName: "Item")
		
		// ordena os resultados alfabetica pelo campo "nome"
		let orderByName                  = NSSortDescriptor(key: "nome", ascending: true, selector: "caseInsensitiveCompare:")
		
		// define o filtro de ordenação
		listagemCoreData.sortDescriptors = [orderByName]
		
		// executa a busca e retorna os valores no array itens
		return managedObjectContext.executeFetchRequest(listagemCoreData, error: nil) as? [Item] ?? []
	}
	
	/// Função para encontrar um Item por nome
	///
	/// :param: nome  Nome do item para buscar
	/// :param: managedObjectContext contexto a ser manipulado
	///
	class func buscar(nome: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> Item? {
		let fetchRequest       = NSFetchRequest(entityName: "Item")
		fetchRequest.predicate = NSPredicate(format: "nome = %@", nome)
		
		let result = managedObjectContext.executeFetchRequest(fetchRequest, error: nil) as? [Item]
		return result?.first
	}
	
	/// Função para verificar se já existe um registro com esse nome
	///
	/// :param: nome  Nome do item para buscar
	/// :param: managedObjectContext contexto a ser manipulado
	///
	class func itemExistente(nome: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> Bool {
		return buscar(nome, inManagedObjectContext: managedObjectContext) != nil
	}
	
	// MARK: - Init
	
	convenience init(nome: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) {
		let entity = NSEntityDescription.entityForName("Item", inManagedObjectContext: managedObjectContext)!
		self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
		self.nome = nome
	}
	
	// MARK: -
	
	/// Função para apagar um item do CoreData
	///
	/// :param: managedObjectContext contexto a ser manipulado
	///
	func apagar(managedObjectContext: NSManagedObjectContext) {
		managedObjectContext.deleteObject(self)
	}
	
	/// Função para salvar os dados no CoreData
	///
	/// :param: managedObjectContext contexto a ser manipulado
	///
	func salvar(managedObjectContext: NSManagedObjectContext) {
		var error: NSErrorPointer = nil
		
		// se a ação salvar falhar, imprime erro
		if(managedObjectContext.save(error)) {
			if (error != nil) {
				println("Erro ao salvar: \(error.debugDescription)")
			}
		}
	}
}

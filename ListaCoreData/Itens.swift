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
class Itens: NSManagedObject {
    
  /// mapeamento do campo "nome" para String
  @NSManaged var nome: String
    
  /// Função para adicionar um item do CoreData de forma rápida
  ///
  /// :param: objectContext Conexão com o CoreData
  /// :param: nome Nome para salvar
  class func criaNovoObjeto(objectContext: NSManagedObjectContext, nome: String) -> Itens {
    let newItem = NSEntityDescription.insertNewObjectForEntityForName("Itens", inManagedObjectContext: objectContext) as! Itens
        
    // fazendo o as! Itens, não precisamos criar o objeto usando setValue, o que simplifica o processo
    newItem.nome = nome
        
    return newItem
  }
}

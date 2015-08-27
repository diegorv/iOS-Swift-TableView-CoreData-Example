//
//  ListaCoreDataFunctions
//  ListaCoreData
//
//  Created by Diego Rossini Vieira on 8/27/15.
//  Copyright (c) 2015 Diego Rossini Vieira. All rights reserved.
//

import UIKit
import CoreData

class ListaCoreDataFunctions: UIViewController {
  
   /* ----------------------------------------------------------------------------------------------------- */
  
  // MARK: VARIAVEIS
  
  /// Variavel da "conexão" com o CoreData
  let coreDataDB = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
  
  /// Array de itens do sistema
  var itens      = [Itens]()
  
  /* ----------------------------------------------------------------------------------------------------- */
  
  // MARK: FUNÇÕES
  
  /// Função para carregar os dados do CoreData, direto no array
  func carregaDadosCoreData() {
    let listagemCoreData             = NSFetchRequest(entityName: "Itens")
    
    // ordena os resultados alfabetica pelo campo "nome"
    let orderByName                  = NSSortDescriptor(key: "nome", ascending: true, selector: "caseInsensitiveCompare:")

    // define o filtro de ordenação
    listagemCoreData.sortDescriptors = [orderByName]

    // executa a busca e retorna os valores no array itens
    if let listagemResultados = coreDataDB.executeFetchRequest(listagemCoreData, error: nil) as? [Itens] {
      itens = listagemResultados
    }
  }
  
  /// Função para verificar se já existe um registro com esse nome
  ///
  /// :param:  nomeBusca  Nome do item para buscar
  ///
  func itemExistente(nomeBusca: String) -> Bool {
    let listagemCoreData       = NSFetchRequest(entityName: "Itens")
    listagemCoreData.predicate = NSPredicate(format: "nome = %@", nomeBusca)
    let resultadosBusca        = coreDataDB.executeFetchRequest(listagemCoreData, error: nil) as? [Itens]
    
    return (resultadosBusca!.count >= 1 ? true : false)
  }
  
  /// Função para adicionar item no CoreData
  ///
  /// :param: tableView Referencia do Outlet da TableView
  /// :param:  nome  Nome do item para adicionar no coreData
  ///
  func adicionaItem(tableView: UITableView, nome: String) {
    // chama uma função da classe "Itens" que já faz o processo de criar o novo objeto do CoreData
    var novoItem = Itens.criaNovoObjeto(coreDataDB, nome: nome)
    
    // adiciona no final do array de itens o novo item
    itens.append(novoItem)
    
    // salva os dados
    self.salvaCoreData()
    
    // recarrega os itens, se deixar descomentado essa linha aqui, ele vai adicionar o item na tableView na ordem alfabetica
    self.carregaDadosCoreData()
    
    // recarrega a TableView
    tableView.reloadData()
  }
  
  /// Função para editar o nome do Item
  ///
  /// :param: nomeAtual Nome atual do item
  /// :param: nomeAtual Novo nome do item
  ///
  func atualizarItem(nomeAtual: String, novoNome: String) {
    let fetchRequest       = NSFetchRequest(entityName: "Itens")
    fetchRequest.predicate = NSPredicate(format: "nome = %@", nomeAtual)

    let result = coreDataDB.executeFetchRequest(fetchRequest, error: nil) as? [Itens]
    result?.first!.nome = novoNome
    
    self.salvaCoreData()
  }
  
  /// Função para apagar um item do CoreData
  ///
  /// :param: itemApagar Referencia objeto do item para apagar
  ///
  func apagarItem(itemApagar: Itens) {
    coreDataDB.deleteObject(itemApagar)
  }
  
  /// Função para salvar os dados no CoreData
  func salvaCoreData() {
    var error : NSError?
    
    // se a ação salvar falhar, imprime erro
    if(coreDataDB.save(&error) ) {
      if (error != nil) {
        println("Erro ao salvar: \(error?.localizedDescription)")
      }
    }
  }

// end
}

//
//  AppDelegate.swift
//  ListaCoreData
//
//  Created by Diego Rossini Vieira on 8/26/15.
//  Copyright (c) 2015 Diego Rossini Vieira. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {
  
  // MARK: - Variaveis
  
  /// Variavel da "conexão" com o CoreData
  let coreDataDB = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
  
  /// Array de itens do sistema
  var itens      = [Itens]()
  
  // MARK: - Outlets
  
  // Outlet da TableView
	@IBOutlet weak var tableView: UITableView!
	
  // MARK: - View Lifecycle
  
	override func viewDidLoad() {
		super.viewDidLoad()

    // Título do NavigationController
		title = "A lista"
		tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
  
    // carrega os dados do CoreData
    itens = Itens.buscarTodos(coreDataDB)
	}
	
  // MARK: - Actions
  
  // Ação de adicionar item na TableView
	@IBAction func addButton(sender: UIBarButtonItem) {
		var alerta          = UIAlertController(title: "Novo item", message: "Insira um nome para o item", preferredStyle: .Alert)
		let botaoSalvar     = UIAlertAction    (title: "Salvar", style: .Default) { (action: UIAlertAction!) -> Void in
			let textField     = alerta.textFields![0] as! UITextField
      let nomeAdicionar = textField.text
      
      // Verifica se o nome está em branco
      if (nomeAdicionar.isEmpty) {
        self.alertaError("Erro ao salvar item", msg: "O nome do item não pode ficar em branco")
      }
      // Verifica se o item já existe
      else if (Itens.itemExistente(nomeAdicionar, inManagedObjectContext: self.coreDataDB)) {
        self.alertaError("Erro ao salvar item", msg: "Já existe um item com o nome: \(nomeAdicionar) \n Não é possível salvar dois nomes iguais")
      }
      // Salva no CoreData
      else {
        self.adicionaItem(self.tableView, nome: nomeAdicionar)
        self.tableView.reloadData()
      }
		}
		
    // Como não teremos ação no "cancelar", não precisa de handler
		let botaoCancelar = UIAlertAction(title: "Cancelar", style: .Destructive, handler: nil)
		
    // Essa função é necessária para o textField aparecer no alerta, no meu caso eu adicionei um "placeholder" para melhorar a interface
    // caso você não queira fazer isso, apenas chamar da seguinte forma
    // alert.addTextFieldWithConfigurationHandler(nil)
		alerta.addTextFieldWithConfigurationHandler { textField in
			textField.placeholder = "Nome"
		}
		
		alerta.addAction(botaoSalvar)
		alerta.addAction(botaoCancelar)
		
		presentViewController(alerta, animated: true, completion: nil)
	}
  
  // MARK: - Helpers
  
  /// Função para adicionar item no CoreData
  ///
  /// :param: tableView Referencia do Outlet da TableView
  /// :param:  nome  Nome do item para adicionar no coreData
  ///
  /// AVISO: Esse exemplo eu passo a referencia da TableView do ViewController, só pra servir como exemplo mesmo
  /// teoricamente seria melhor não fazer isso.
  func adicionaItem(tableView: UITableView, nome: String) {
    // chama uma função da classe "Itens" que já faz o processo de criar o novo objeto do CoreData
    var novoItem = Itens(nome: nome, inManagedObjectContext: coreDataDB)
    
    // adiciona no final do array de itens o novo item
    itens.append(novoItem)
    
    // salva os dados
    novoItem.salvar(coreDataDB)
    
    // recarrega os itens, se deixar descomentado essa linha aqui, ele vai adicionar o item na tableView na ordem alfabetica
    itens = Itens.buscarTodos(coreDataDB)
    
    // recarrega a TableView
    tableView.reloadData()
  }
  
  /// Função para mostrar um alertView de error
  ///
  /// :param:  title  Título do alerta
  /// :param:  msg    Mensagem do alerta
  ///
  func alertaError(title: String, msg: String) {
    var alertaErro    = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
    let botaoCancelar = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
    
    alertaErro.addAction(botaoCancelar)
    
    self.presentViewController(alertaErro, animated: true, completion: nil)
  }
	
	// MARK: - UITableViewDataSource
    
	// Numero de linhas do TableView
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return itens.count
	}
	
  // Mostra o dado da linha do TableView
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
		
		cell.textLabel?.text = self.itens[indexPath.row].nome
		return cell
	}
	
    // Permite editar/deletar a linha do TableView
	func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
  
  // Permite mostrar os botões no swipe da linha ta TableView
	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
  }
  
  // Ações quando o usuário der swipe no campo da TableView
  func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
    var botaoEditar = UITableViewRowAction(style: .Default, title: "Editar") { (action, indexPath) in
      /* ----------------------------------------------------------------------------------------------------- */
      let nomeAtual   = self.itens[indexPath.row].nome
      
      var alerta      = UIAlertController(title: "Editando item", message: "Altere o nome do item", preferredStyle: .Alert)
      let botaoSalvar = UIAlertAction(title: "Salvar", style: .Default) { (action) in
        let novoNome     = (alerta.textFields![0] as! UITextField).text
        
        // Verifica se o nome está em branco
        if (novoNome.isEmpty) {
          self.alertaError("Erro ao salvar item", msg: "O nome do item não pode ficar em branco")
        }
        // Se o nome atual for igual o nome anterior, não faz nada
        else if (nomeAtual == novoNome) {
          true
        }
        // Verifica se o novo nome já existe
        else if (Itens.itemExistente(novoNome, inManagedObjectContext: self.coreDataDB)) {
          self.alertaError("Erro ao salvar item", msg: "Já existe um item com o nome: \(novoNome) \n Não é possível salvar dois nomes iguais")
        }
        // Salva no CoreData
        else {
          // Chama a função para atualizar o nome
          let item = Itens.buscar(nomeAtual, inManagedObjectContext: self.coreDataDB)
          item?.nome = novoNome
          item?.salvar(self.coreDataDB)
          
          // Racarrega os dados no CoreData
          self.itens = Itens.buscarTodos(self.coreDataDB)
          
          // Recarrega a TableView
          self.tableView.reloadData()
        }
        
        self.tableView.setEditing(false, animated: false)
      }
      
      // Essa função é necessária para o textField aparecer no alerta
      // Mostra o nome atual do item
      alerta.addTextFieldWithConfigurationHandler { textField in
        textField.text = nomeAtual
      }
      
      let botaoCancelar = UIAlertAction(title: "Cancelar", style: .Destructive, handler: nil)
      
      alerta.addAction(botaoCancelar)
      alerta.addAction(botaoSalvar)

      self.presentViewController(alerta, animated: true, completion: nil)
    }
    
    /* ----------------------------------------------------------------------------------------------------- */
    
    var botaoDeletar = UITableViewRowAction(style: .Normal, title: "Deletar") { (action, indexPath) in
      // seleciona o item no array
      let itemApagar = self.itens[indexPath.row]
      
      // apaga o item do coreData
      itemApagar.apagar(self.coreDataDB)
      
      // Salva os itens
      itemApagar.salvar(self.coreDataDB)
      
      // A TableView sempre carrega os elementos do array "itens" que são os dados do CoreData
      // Se você deleta um item do coreData e não recarrega o array, a quantidade de elementos do Array é diferente da quantidade das linhas
      // do tableView e dá erro
      self.itens = Itens.buscarTodos(self.coreDataDB)
      
      // Remove o item da TableView
      self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    botaoEditar.backgroundColor  = UIColor.lightGrayColor()
    botaoDeletar.backgroundColor = UIColor.redColor()
    
    return [botaoDeletar, botaoEditar]
  }

// end
}


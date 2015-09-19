//
//  Item.swift
//  iOS-Swift-TableView-CoreData-Example
//
//  Created by Diego Rossini Vieira on 9/7/15.
//  https://github.com/diegorv/iOS-Swift-TableView-CoreData-Example
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {

  // MARK: - Variables

  /// CoreData connection variable
  let coreDataDB = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

  /// TableView array data
  var items      = [Item]()

  // MARK: - Outlets

  // TableView Outlet
  @IBOutlet weak var tableView: UITableView!

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    // NavigationController title
    title = "My item list"
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")

    // Load CoreData data
    items = Item.fetchAll(coreDataDB)
  }

  // MARK: - Actions

  /// TableView add button
  @IBAction func addButton(sender: UIBarButtonItem) {
    let addFormAlert    = UIAlertController(title: "New item", message: "Enter a name for the item", preferredStyle: .Alert)
    let saveButton      = UIAlertAction    (title: "Save", style: .Default) { (action: UIAlertAction) -> Void in
      let nameTextField = (addFormAlert.textFields![0] ).text

      // Check if name is empty
      if (nameTextField!.isEmpty) {
        self.alertError("Unable to save", msg: "Item name can't be blank.")
      }
      // Check duplicate item name
      else if (Item.checkDuplicate(nameTextField!, inManagedObjectContext: self.coreDataDB)) {
        self.alertError("Unable to save", msg: "There is already an item with name: \(nameTextField).")
      }
      // Save data
      else {
        // Use class "Item" to create a new CoreData object
        let newItem = Item(name: nameTextField!, inManagedObjectContext: self.coreDataDB)

        // Add item to array
        self.items.append(newItem)

        // CoreData save
        newItem.save(self.coreDataDB)

        // Reload Coredata data
        self.items = Item.fetchAll(self.coreDataDB)

        // Reload TableView
        self.tableView.reloadData()
      }
    }

    // No action, no need handler
    let cancelButton = UIAlertAction(title: "Cancel", style: .Destructive, handler: nil)

    // Show textField in alert
    addFormAlert.addTextFieldWithConfigurationHandler { textField in
      textField.placeholder = "Item name"
    }

    addFormAlert.addAction(saveButton)
    addFormAlert.addAction(cancelButton)

    presentViewController(addFormAlert, animated: true, completion: nil)
  }

  // MARK: - UITableViewDataSource

  // TableView rows
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  // Show data in TableView row
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 

    cell.textLabel?.text = self.items[indexPath.row].name
    return cell
  }

  // Allow edit cell in TableView
  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }

  // Allow actions on cell swipe in TableView
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
  }

  // Actions on cell swipe in TableView
  func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
    let editSwipeButton = UITableViewRowAction(style: .Default, title: "Edit") { (action, indexPath) in
      let currentName = self.items[indexPath.row].name

      let alertEdit   = UIAlertController(title: "Editing item", message: "Change item name", preferredStyle: .Alert)
      let saveButton  = UIAlertAction(title: "Save", style: .Default) { (action) in
        let newItemName = (alertEdit.textFields![0] ).text

        // Check if name is empty
        if (newItemName!.isEmpty) {
          self.alertError("Unable to save", msg: "Item name can't be blank.")
        }
        // Current Name equal New Name
        else if (currentName == newItemName) {
          true // do nothing
        }
        // Check duplicate item name
        else if (Item.checkDuplicate(newItemName!, inManagedObjectContext: self.coreDataDB)) {
          self.alertError("Unable to save", msg: "There is already an item with name: \(newItemName).")
        }
        // Save CoreData
        else {
          // Update item name
          let item = Item.search(currentName, inManagedObjectContext: self.coreDataDB)
          item?.name = newItemName!
          item?.save(self.coreDataDB)

          // Reload Coredata data
          self.items = Item.fetchAll(self.coreDataDB)

          // Reload TableView
          self.tableView.reloadData()
        }

        // Close cell buttons
        self.tableView.setEditing(false, animated: false)
      }

      let cancelButton = UIAlertAction(title: "Cancel", style: .Destructive, handler: nil)

      // Show textField in alert with current name value
      alertEdit.addTextFieldWithConfigurationHandler { textField in
        textField.text = currentName
      }

      alertEdit.addAction(cancelButton)
      alertEdit.addAction(saveButton)

      self.presentViewController(alertEdit, animated: true, completion: nil)
    }

    let deleteSwipteButton = UITableViewRowAction(style: .Normal, title: "Delete") { (action, indexPath) in
      // Find item
      let itemDelete = self.items[indexPath.row]

      // Delete item in CoreData
      itemDelete.destroy(self.coreDataDB)

      // Save item
      itemDelete.save(self.coreDataDB)

      // Tableview always load data from "items" array.
      // If you delete a item from CoreData you need reload array data.
      self.items = Item.fetchAll(self.coreDataDB)

      // Remove item from TableView
      self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    editSwipeButton.backgroundColor    = UIColor.lightGrayColor()
    deleteSwipteButton.backgroundColor = UIColor.redColor()

    return [editSwipeButton, deleteSwipteButton]
  }

  // MARK: - Helpers

  /// Show a alert error
  ///
  /// - parameter  title:  Title
  /// - parameter  msg:    Message
  ///
  func alertError(title: String, msg: String) {
    let alert    = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
    let okButton = UIAlertAction(title: "OK", style: .Cancel, handler: nil)

    alert.addAction(okButton)

    self.presentViewController(alert, animated: true, completion: nil)
  }

}


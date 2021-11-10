//
//  CategoryTableVC.swift
//  ToDoList
//
//  Created by Aleksandr Khalupa on 02.04.2021.
//

import UIKit
import RealmSwift


class CategoryTableVC: UITableViewController {
    
    
    var categoriesArray: Results<AHCategory>?
    var localRealm:Realm?{
        do {
            return try Realm()
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        readData()
    }
    
    @IBAction func pressedEditCategory(_ sender: UIBarButtonItem) {
        
        if tableView.isEditing{
            tableView.setEditing(false, animated: true)
            sender.title = "Edit"
        } else{
            tableView.setEditing(true, animated: true)
            sender.title = "Done"
        }
    }
    
    
    
    @IBAction func pressedAddCategory(_ sender: UIBarButtonItem) {
        
        var textFied = UITextField()
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (alertAction) in
            
            let category = AHCategory()
            category.name = textFied.text!
            self.saveData(category: category)
            self.tableView.reloadData()
        }
        
        alert.addTextField { (textF) in
            textF.placeholder = "input text"
            textFied = textF
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedRow = tableView.indexPathForSelectedRow?.row else{return}
        if segue.identifier == "goToItem"{
            let itemTableVC = segue.destination as! TableVC
            itemTableVC.selectedCategory = categoriesArray?[selectedRow]
        }
    }
    
    //    MARK: - Save & Read DATA
    
    func saveData(category:AHCategory){
        guard let safeRealm = localRealm else {
            return
        }
        do {
            try safeRealm.write {
                safeRealm.add(category)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func readData(){
        guard let safeRealm = localRealm else {
            return
        }
        let categories = safeRealm.objects(AHCategory.self)
        categoriesArray = categories
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoriesArray?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = categoriesArray?[indexPath.row].name
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItem", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if let cat = categoriesArray?[indexPath.row]{
            guard let safeRealm = localRealm else {
                return
            }
            do {
                try safeRealm.write {
                    safeRealm.delete(cat.items)
                    safeRealm.delete(cat)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        tableView.reloadData()
        
    }
}

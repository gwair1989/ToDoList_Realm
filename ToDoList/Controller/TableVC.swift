//
//  TableVC.swift
//  ToDoList
//
//  Created by Aleksandr Khalupa on 16.03.2021.
//

import UIKit
import RealmSwift



class TableVC: UITableViewController, UISearchBarDelegate{


    @IBOutlet weak var searchField: UISearchBar!
    
    var listArray: Results<AHList>?
    
    var selectedCategory: AHCategory?{
        didSet{
            readData()
        }
    }
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
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true))
        print(Realm.Configuration.defaultConfiguration.fileURL!)
       
    }
    
    @IBAction func pessedAdd(_ sender: UIBarButtonItem) {
        var textFied = UITextField()
        let alert = UIAlertController(title: "Add new item", message: "For your list", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (alertAction) in
            if let currentCategory = self.selectedCategory{
                
                guard let safeRealm = self.localRealm else {
                    return
                }
                do {
                    try safeRealm.write {
                        let item = AHList()
                        item.item = textFied.text!
                        item.date = Date()
                        currentCategory.items.append(item)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { (textF) in
            textF.placeholder = "input text"
            textFied = textF
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //    MARK: - Save & Read DATA
    
    func saveData(item:AHList){
        guard let safeRealm = localRealm else {
            return
        }
        do {
            try safeRealm.write {
                safeRealm.add(item)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func readData(){
       listArray = selectedCategory?.items.sorted(byKeyPath: "date", ascending: true)
    }
    
    //    MARK: - TableVC

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        
        if let list = listArray?[indexPath.row] {
            cell.textLabel?.text = list.item
            cell.accessoryType = list.isCheck ? .checkmark : .none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let list = listArray?[indexPath.row] {
            guard let safeRealm = localRealm else {
                return
            }
            do {
                try safeRealm.write {
                    list.isCheck = !list.isCheck
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if let item = listArray?[indexPath.row]{
            guard let safeRealm = localRealm else {
                return
            }
            do {
                try safeRealm.write {
                    safeRealm.delete(item)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        tableView.reloadData()
    }

    //    MARK: - Search

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchInDB(text: searchText, searchBar: searchBar)
    }
    
    func searchInDB(text:String, searchBar: UISearchBar){
        
        if text != ""{
            listArray = listArray?.filter("item CONTAINS[cd] %@", text).sorted(byKeyPath: "item", ascending: true)
        } else{
            self.readData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        tableView.reloadData()
    }
}

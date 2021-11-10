//
//  AHList.swift
//  ToDoList
//
//  Created by Aleksandr Khalupa on 27.04.2021.
//

import Foundation
import RealmSwift


class AHList:Object{
    @objc dynamic var item = ""
    @objc dynamic var isCheck = false
    @objc dynamic var date = Date()
    
    let categoryRel = LinkingObjects(fromType: AHCategory.self, property: "items")
}

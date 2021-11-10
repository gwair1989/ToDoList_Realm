//
//  AHCategory.swift
//  ToDoList
//
//  Created by Aleksandr Khalupa on 27.04.2021.
//

import Foundation
import RealmSwift

class AHCategory:Object{
    @objc dynamic var name = ""
    
    let items = List<AHList>()
}

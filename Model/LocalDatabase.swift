//
//  LocalDatabase.swift
//  MessageBoard
//
//  Created by imac-1763 on 2023/1/21.
//

import Foundation
import RealmSwift
class LocalDatabase: NSObject{
    
    
}
class MessageTable: Object{
    @Persisted var name: String
    @Persisted var context: String
    @Persisted var timestamp: Int64
    
}


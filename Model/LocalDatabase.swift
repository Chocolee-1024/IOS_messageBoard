//
//  LocalDatabase.swift
//  MessageBoard
//
//  Created by imac-1763 on 2023/1/21.
//

import Foundation
import RealmSwift
class LocalDatabase: NSObject{
    private static var share: LocalDatabase?
    
    //Singleton模式
    static func SharedInstance() -> LocalDatabase{
        if share == nil{
            share = LocalDatabase()
        }
        return share!
    }
    /**
     原本寫法是放在if裡，所以當我刪掉資料變0時不會進刷新資料。
     刷新資料拿出來後就會從整，但Array裡你刪掉的最後一筆還會在因為部會進if裡，所以不會把Array清空，應此要把Array清空拿出來。
     */
    //撈取全部留言
    func fetchFromDatabase() -> [Message]{
        var messageArray: [Message] = []
        let realms = try! Realm()
        let results = realms.objects(MessageTable.self)
        if results.count > 0{
            for i in results{
                messageArray.append(Message(name: i.name, context: i.context, timestamp: i.timestamp))
            }
        }
        return messageArray
    }
    
    //新增留言
    func addMessage(message: Message){
        let realm = try! Realm()
        let table = MessageTable()
        table.name = message.name
        table.context = message.context
        table.timestamp = message.timestamp
        do{
            try realm.write{
                realm.add(table)
                print("File URL : \(String(describing: realm.configuration.fileURL?.absoluteURL))")
            }
        } catch {
            print("Realm Add Failed : \(error.localizedDescription)")
        }
    }
    
    //刪除留言
    func deleteMessage(message: Message){
        let realm = try! Realm()
        if let deleteMessage = realm.objects(MessageTable.self).filter("timestamp = \(message.timestamp)").first{
            do{
                try realm.write{
                    realm.delete(deleteMessage)
                    print("File URL : \(String(describing: realm.configuration.fileURL?.absoluteURL))")
                }
            } catch {
                print("Realm Add Failed : \(error.localizedDescription)")
            }
        }
    }
    
    //更新留言
    func UpdataMessage(message: Message,messagePeople: String, messageContext: String){
        let realm = try! Realm()
        if let updataMesssage = realm.objects(MessageTable.self).filter("timestamp = \(message.timestamp)").first{
                try! realm.write{
                    updataMesssage.name = messagePeople
                    updataMesssage.context = messageContext
                    print("File URL : \(String(describing: realm.configuration.fileURL?.absoluteURL))")
                }
        }
    }
    
    //排序留言
    func SortMessage(index: Int){
        let realm = try! Realm()
        var results = realm.objects(MessageTable.self)
        switch(index) {
        case 0:
            print("選擇「預設」排序方式")
            results = realm.objects(MessageTable.self).sorted(byKeyPath: "timestamp")
        case 1:
            print("選擇「舊到新」排序方式")
            results = realm.objects(MessageTable.self).sorted(byKeyPath: "timestamp",ascending: false)
        case 2:
            print("選擇「新到舊」排序方式")
            results = realm.objects(MessageTable.self).sorted(byKeyPath: "timestamp")
        default:
            break
        }
        var tableList: [MessageTable] = []
        for result in results{
            let table = MessageTable()
            table.name = result.name
            table.context = result.context
            table.timestamp = result.timestamp
            tableList.append(table)
        }
        try! realm.write(){
            realm.deleteAll()
        }
        for table in tableList{
            try! realm.write(){
                realm.add(table)
            }
        }
    }
    
}
class MessageTable: Object{
    @Persisted var name: String
    @Persisted var context: String
    @Persisted var timestamp: Int64
    
}


//
//  RealmManager.swift
//  MemoApp_TCA
//
//  Created by 이은재 on 2023/05/03.
//

import Foundation
import RealmSwift

struct RealmManager {
    private(set) var localRealm: Realm?
    
    init() {
        openRealm()
    }
    
    mutating func openRealm() {
        do {
            let config = Realm.Configuration(schemaVersion: 1)
            Realm.Configuration.defaultConfiguration = config
            self.localRealm = try Realm()
        } catch {
            print("Error opening Realm : \(error)")
        }
    }
    
    func findAllMemo() -> [Memo] {
        if let localRealm = localRealm {
            let allMemo = localRealm.objects(Memo.self).sorted(byKeyPath: "date")
            var result = [Memo]()
            allMemo.forEach { memo in
                result.append(memo)
            }
            return result
        } else {
            return []
        }
    }
    
    func findMemo(_ id: ObjectId) -> Memo? {
        if let localRealm = localRealm {
            let memoToFind = localRealm.objects(Memo.self).filter(NSPredicate(format: "id == %@", id))
            guard !memoToFind.isEmpty else { return nil }
            return memoToFind.first
            
        } else {
            return nil
        }
    }
    
    func addMemo(memo: Memo) {
        if let localRealm = localRealm {
            do {
                try localRealm.write {
                    localRealm.add(memo)
                    print("Added new memo to Realm : \(memo)")
                }
            } catch {
                print("Error adding memo to Realm : \(error)")
            }
        }
    }
    
    func deleteMemo(_ id: ObjectId) {
        if let localRealm = localRealm {
            do {
                let memoToDelete = localRealm.objects(Memo.self).filter(NSPredicate(format: "id == %@", id))
                guard !memoToDelete.isEmpty else { return }
                
                try localRealm.write {
                    localRealm.delete(memoToDelete)
                    print("Deleted memo with id : \(id)")
                }
                
            } catch {
                print("Error deleting memo \(id) from Realm: \(error)")
            }
        }
    }
    
    func updateMemo(id: ObjectId, text: String, color: String) {
        if let localRealm = localRealm {
            do {
                if let memoToUpdate = localRealm.objects(Memo.self).filter(NSPredicate(format: "id == %@", id)).first {
                    try localRealm.write {
                        memoToUpdate.date = Date.now
                        memoToUpdate.text = text
                        memoToUpdate.color = color
                    }
                    print("updated memo with id : \(id)")
                }
            } catch {
                print("Error updating memo \(id) from Realm: \(error)")
            }
        }
    }
}

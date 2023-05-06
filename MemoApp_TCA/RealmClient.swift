//
//  RealmManager.swift
//  MemoApp_TCA
//
//  Created by 이은재 on 2023/05/03.
//

import Foundation
import RealmSwift
import ComposableArchitecture
import XCTestDynamicOverlay


struct RealmClient {
    var findAllMemo: @Sendable() -> [Memo]
    var findMemo: @Sendable(_ id: ObjectId) -> Memo?
    var addMemo: @Sendable(_ memo: Memo) -> Void
    var deleteMemo: @Sendable(_ id: ObjectId) -> Void
    var updateMemo: @Sendable(_ id: ObjectId, _ text: String, _ color: String) -> Void
    
}

extension DependencyValues {
    var realmClient: RealmClient {
        get { self[RealmClient.self] }
        set { self[RealmClient.self] = newValue }
    }
}

extension RealmClient: DependencyKey {
    static var liveValue = RealmClient(
        findAllMemo: {
            let realm = try! Realm(configuration: .init(schemaVersion: 2))
            let allMemo = realm.objects(Memo.self).sorted(byKeyPath: "date")
            var result = [Memo]()
            allMemo.forEach { memo in
                result.append(memo)
            }
            return result
        },
        findMemo: { id in
            let realm = try! Realm(configuration: .init(schemaVersion: 2))
            let memoToFind = realm.objects(Memo.self).filter(NSPredicate(format: "id == %@", id))
            guard !memoToFind.isEmpty else { return nil }
            return memoToFind.first
        },
        addMemo: { memo in
            let realm = try! Realm(configuration: .init(schemaVersion: 2))
            do {
                try realm.write {
                    realm.add(memo)
                    print("Added new memo to Realm : \(memo)")
                }
            } catch {
                print("Error adding memo to Realm : \(error)")
            }
        },
        deleteMemo: { id in
            let realm = try! Realm(configuration: .init(schemaVersion: 2))
            do {
                let memoToDelete = realm.objects(Memo.self).filter(NSPredicate(format: "id == %@", id))
                guard !memoToDelete.isEmpty else { return }
                
                try realm.write {
                    realm.delete(memoToDelete)
                    print("Deleted memo with id : \(id)")
                }
                
            } catch {
                print("Error deleting memo \(id) from Realm: \(error)")
            }
        },
        updateMemo: { id, text, color in
            let realm = try! Realm(configuration: .init(schemaVersion: 2))
            do {
                if let memoToUpdate = realm.objects(Memo.self).filter(NSPredicate(format: "id == %@", id)).first {
                    try realm.write {
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
    )
    
    
    
}

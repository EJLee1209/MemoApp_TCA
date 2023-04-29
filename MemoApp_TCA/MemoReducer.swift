//
//  MemoReducer.swift
//  MemoApp_TCA
//
//  Created by 이은재 on 2023/04/29.
//

import Foundation
import ComposableArchitecture
import RealmSwift

// Feature 자체가 ReducerProtocol을 준수하며, 내부에서 실제 reduce function을 통해 논리, 동작을 처리한다
struct MemoFeature : ReducerProtocol {
    private(set) var localRealm: Realm?
    
    init() {
        openRealm()
    }
    
    // 도메인(어떤걸 만들 때 거기에 대한 데이터) + 상태
    struct MemoState: Equatable {
        var memos: [Memo] = []
        var selectedMemo: Memo? = nil
    }
    
    // 도메인 + 액션 (액션을 통해 상태를 변경함)
    enum MemoAction: Equatable {
        case findAllMemo
        case findMemo(_ id: ObjectId)
        case addMemo(_ memo: Memo)
        case deleteMemo(_ id: ObjectId)
        case updateMemo(id: ObjectId, text: String, color: String)
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
    
    // 리듀서 : 액션과 상태를 연결시켜주는 역할
    func reduce(into state: inout MemoState, action: MemoAction) -> EffectTask<MemoAction> {
        switch action {
        case .findAllMemo:
            state.memos = findAllMemo()
            return .none
        case .findMemo(let id):
            state.selectedMemo = findMemo(id)
            return .none
        case .addMemo(let memo):
            addMemo(memo: memo)
            state.memos = findAllMemo()
            return .none
        case .deleteMemo(let id):
            deleteMemo(id)
            state.memos = findAllMemo()
            return .none
        case .updateMemo(let id, let text, let color):
            updateMemo(id: id, text: text, color: color)
            state.memos = findAllMemo()
            return .none
        }
    }
}

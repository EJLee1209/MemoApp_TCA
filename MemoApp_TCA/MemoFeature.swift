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
    let realmManger = RealmManager()
    
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
    
    
    // 리듀서 : 액션과 상태를 연결시켜주는 역할
    func reduce(into state: inout MemoState, action: MemoAction) -> EffectTask<MemoAction> {
        switch action {
        case .findAllMemo:
            state.memos = realmManger.findAllMemo()
            return .none
        case .findMemo(let id):
            state.selectedMemo = realmManger.findMemo(id)
            return .none
        case .addMemo(let memo):
            realmManger.addMemo(memo: memo)
            state.memos = realmManger.findAllMemo()
            return .none
        case .deleteMemo(let id):
            realmManger.deleteMemo(id)
            state.memos = realmManger.findAllMemo()
            return .none
        case .updateMemo(let id, let text, let color):
            realmManger.updateMemo(id: id, text: text, color: color)
            state.memos = realmManger.findAllMemo()
            return .none
        }
    }
}

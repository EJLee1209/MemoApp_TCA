//
//  ContentView.swift
//  MemoApp_TCA
//
//  Created by 이은재 on 2023/04/29.
//
import SwiftUI
import ComposableArchitecture
import RealmSwift

//MARK: - ReducerProtocol을 따르는 Root
// Feature 자체가 ReducerProtocol을 준수하며, 내부에서 실제 reduce function을 통해 논리, 동작을 처리한다
struct Root : ReducerProtocol {
    
    // 도메인(어떤걸 만들 때 거기에 대한 데이터) + 상태
    struct State: Equatable {
        var memos: [Memo] = []
        var selectedMemo: Memo? = nil
        var sortValue: String = "Color"
        // EditorView 에 대한 State를 가지고 있어야 함.
        var memoEditorState = MemoEditorFeature.State()
        var radioButtonState = RadioFeature.State() // 정렬 기준
    }
    
    // 도메인 + 액션 (액션을 통해 상태를 변경함)
    enum Action: Equatable {
        case findAllMemo
        case deleteMemo(_ id: ObjectId)
        case radioButtonTapped(_ value: String)
        case sortMemos
        
        case goToMemoEditorView(MemoEditorFeature.Action)
        case radioButtonAction(RadioFeature.Action)
        case onAppear
    }
    
    
    @Dependency(\.realmClient) var realmClient // RealmClient 의존성 주입
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .findAllMemo:
                state.memos = realmClient.findAllMemo()
                return EffectTask.run { send in
                    await send.send(.sortMemos)
                }
            case .deleteMemo(let id):
                realmClient.deleteMemo(id)
                state.memos = realmClient.findAllMemo()
                return .none
            case .radioButtonTapped(let value):
                state.sortValue = value
                return EffectTask.run { send in
                    await send.send(.sortMemos)
                }
            case .sortMemos:
                switch state.sortValue{
                case "Color":
                    state.memos = state.memos.sorted { $0.color < $1.color }
                case "Date":
                    state.memos = state.memos.sorted { $0.date < $1.date }
                case "Text":
                    state.memos = state.memos.sorted { $0.text < $1.text }
                default:
                    break
                }
                return .none
            case .onAppear:
                state = .init()
                return .none
            default:
                return .none
            }
        }
        Scope(state: \.memoEditorState, action: /Action.goToMemoEditorView) {
            MemoEditorFeature()
        }
        Scope(state: \.radioButtonState, action: /Action.radioButtonAction) {
            RadioFeature()
        }
        
    }
    
}

// MARK: - ContentView
struct ContentView: View {
    let store: StoreOf<Root>
    let filterValues = [
        "Color",
        "Date",
        "Text"
    ]
    let sortDirection = [
        "오름차순",
        "내림차순"
    ]
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                VStack{
                    RadioButton(
                        store: self.store.scope(
                            state: \.radioButtonState,
                            action: Root.Action.radioButtonAction
                        ),
                        values: filterValues
                    ).padding([.horizontal, .top], 20)
                    List {
                        ForEach(viewStore.memos, id:\.id) { memo in
                            if !memo.isInvalidated && !memo.isFrozen {
                                NavigationLink {
                                    MemoEditorView(
                                        mode: .update,
                                        memo: memo,
                                        store: self.store.scope(
                                            state: \.memoEditorState,
                                            action: Root.Action.goToMemoEditorView
                                        )
                                    )
                                } label: {
                                    MemoItem(memo)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                let memoToDelete = viewStore.memos[index]
                                viewStore.send(.deleteMemo(memoToDelete.id))
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        viewStore.send(.findAllMemo)
                    }
                    .navigationTitle("메모")
                    .toolbar {
                        NavigationLink {
                            MemoEditorView(
                                store: self.store.scope(
                                    state: \.memoEditorState,
                                    action: Root.Action.goToMemoEditorView
                                )
                            )
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 25))
                                .bold()
                                .foregroundColor(Color("title_color"))
                        }

                    }
                }
                
            }.tint(.white)
                .onAppear {
                    print("onAppear")
                    viewStore.send(.findAllMemo)
                    viewStore.send(.radioButtonTapped("Color"))
                }
                .onChange(of: viewStore.memoEditorState.isCompleted) { isCompleted in
                    if isCompleted {
                        viewStore.send(.findAllMemo)
                    }
                }
                .onChange(of: viewStore.radioButtonState.selected) { selected in
                    viewStore.send(.radioButtonTapped(filterValues[selected]))
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store: Store(initialState: Root.State(), reducer: Root())
        )
    }
}

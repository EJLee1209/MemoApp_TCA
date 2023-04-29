//
//  ContentView.swift
//  MemoApp_TCA
//
//  Created by 이은재 on 2023/04/29.
//
import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: StoreOf<MemoFeature>
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                List {
                    ForEach(viewStore.memos, id: \.id) { memo in
                        if !memo.isInvalidated && !memo.isFrozen {
                            NavigationLink {
                                MemoEditorView(
                                    mode: .update,
                                    memo: memo,
                                    updateMemo: { id, text, color in
                                        viewStore.send(.updateMemo(id: id, text: text, color: color))
                                    }
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
                            addMemo: { memo in
                                viewStore.send(.addMemo(memo))
                            }
                        )
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 25))
                            .bold()
                            .foregroundColor(Color("title_color"))
                    }

                }
            }.tint(.white)
                .onAppear {
                    viewStore.send(.findAllMemo)
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store: Store(initialState: MemoFeature.MemoState(), reducer: MemoFeature())
        )
    }
}

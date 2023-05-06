//
//  MemoEditorView.swift
//  MemoApp_TCA
//
//  Created by 이은재 on 2023/04/29.
//

import SwiftUI
import RealmSwift
import ComposableArchitecture

// MARK: - ReducerProtocol을 따르는 MemoEditorFeature
struct MemoEditorFeature: ReducerProtocol {
    struct State: Equatable {
        var text: String = ""
        var color: String = Constant.blue
        var alert: AlertState<Action>?
        var confirmDialog: ConfirmationDialogState<Action>?
        var isCompleted: Bool = false
    }
    
    enum Action: Equatable {
        case addMemo
        case updateMemo(id: ObjectId)
        case changedText(_ newValue: String)
        case changedColor(_ newValue: String)
        
        case alertDissmissed
        case addButtonTapped
        case updateButtonTapped(id: ObjectId)
        case confirmationDailogDismissed
        case disappear
    }
    
    @Dependency(\.realmClient) var realmClient // RealmClient 의존성 주입
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .addButtonTapped:
            state.confirmDialog = ConfirmationDialogState(title: {
                TextState("메모를 추가하시겠습니까?")
            }, actions: {
                ButtonState(action: .addMemo) {
                    TextState("추가하기")
                }
                ButtonState(role: .cancel) {
                    TextState("취소")
                }
            })
            return .none
        case .addMemo:
            let memo = Memo(value: [
                "text": state.text,
                "color": state.color
            ])
            realmClient.addMemo(memo)
            state.alert = AlertState(title: {
                TextState("메모가 추가됐습니다")
            }, actions: {
                ButtonState(role: .cancel) {
                    TextState("확인")
                }
            })
            return .none
        case let .updateButtonTapped(id):
            state.confirmDialog = ConfirmationDialogState(title: {
                TextState("메모를 수정하시겠습니까?")
            }, actions: {
                ButtonState(action: .updateMemo(id: id)) {
                    TextState("수정하기")
                }
                ButtonState(role: .cancel) {
                    TextState("취소")
                }
            })
            return .none
        case let .updateMemo(id):
            realmClient.updateMemo(id, state.text, state.color)
            state.alert = AlertState(title: {
                TextState("메모를 수정했습니다")
            }, actions: {
                ButtonState(role: .cancel) {
                    TextState("확인")
                }
            })
            return .none
        case let .changedText(newValue):
            state.text = newValue
            return .none
        case let .changedColor(newValue):
            state.color = newValue
            return .none
            
        case .alertDissmissed:
            state.alert = nil
            state.isCompleted.toggle()
            return .none
        case .confirmationDailogDismissed:
            state.confirmDialog = nil
            return .none
        case .disappear:
            state.isCompleted=false
            state.color=Constant.blue
            state.text=""
            return .none
            
        }
    }
}

//MARK: - 메모 추가인지 수정인지 판단하기 위한 열거형
enum Mode {
    case add, update
}

// MARK: - MemoEditorView
struct MemoEditorView: View {
    @Environment(\.dismiss) var dismiss
    let placeHolder = "내용을 입력해주세요"
    var mode: Mode = .add
    var memo: Memo?
    let store: StoreOf<MemoEditorFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack(alignment: .bottom) {
                Color(viewStore.color)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: Binding(
                            get: { viewStore.text },
                            set: { viewStore.send(.changedText($0)) }
                        ))
                            .font(.body)
                            .foregroundColor(Color(.white))
                            .disableAutocorrection(true)
                            .submitLabel(.done)
                            .scrollContentBackground(.hidden)
                            .padding()
                        
                        if(viewStore.text.isEmpty) {
                            Text(placeHolder)
                                .font(.body)
                                .foregroundColor(Color(.white))
                                .padding()
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                    }
                    HStack(alignment: .center, spacing: 8) {
                        Circle()
                            .frame(width: viewStore.color == Constant.blue ? 60 : 50, height: viewStore.color == Constant.blue ? 60 : 50)
                            .foregroundColor(Color(Constant.blue))
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 2)
                                    .foregroundColor(Color.white)
                            }
                            .onTapGesture {
                                viewStore.send(.changedColor(Constant.blue))
                            }
                        Circle()
                            .frame(width: viewStore.color == Constant.pink ? 60 : 50, height: viewStore.color == Constant.pink ? 60 : 50)
                            .foregroundColor(Color(Constant.pink))
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 2)
                                    .foregroundColor(Color.white)
                            }
                            .onTapGesture {
                                viewStore.send(.changedColor(Constant.pink))
                            }
                        Circle()
                            .frame(width: viewStore.color == Constant.green ? 60 : 50, height: viewStore.color == Constant.green ? 60 : 50)
                            .foregroundColor(Color(Constant.green))
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 2)
                                    .foregroundColor(Color.white)
                            }
                            .onTapGesture {
                                viewStore.send(.changedColor(Constant.green))
                            }
                        Circle()
                            .frame(width: viewStore.color == Constant.purple ? 60 : 50, height: viewStore.color == Constant.purple ? 60 : 50)
                            .foregroundColor(Color(Constant.purple))
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 2)
                                    .foregroundColor(Color.white)
                            }
                            .onTapGesture {
                                viewStore.send(.changedColor(Constant.purple))
                            }
                    }
                    
                }
            }
            .animation(.default, value: viewStore.color)
            .toolbar {
                if mode == .add {
                    Button {
                        viewStore.send(.addButtonTapped)
                    } label: {
                        Text("저장하기")
                            .foregroundColor(.white)
                    }
                } else {
                    Button {
                        if let memo = memo {
                            viewStore.send(.updateButtonTapped(id: memo.id))
                        }
                    
                    } label: {
                        Text("수정완료")
                            .foregroundColor(.white)
                    }
                }
            }
            .onAppear {
                if let memo = memo {
                    viewStore.send(.changedText(memo.text))
                    viewStore.send(.changedColor(memo.color))
                }
            }
            .onDisappear{
                viewStore.send(.disappear)
            }
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog(
                self.store.scope(state: \.confirmDialog),
                dismiss: .confirmationDailogDismissed
            )
            .alert(
                self.store.scope(state: \.alert),
                dismiss: .alertDissmissed
            )
            .onChange(of: viewStore.isCompleted) { isCompleted in
                if isCompleted {
                    dismiss()
                }
            }
            
        }
    }
}

struct MemoEditorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MemoEditorView(
                store: Store(initialState: MemoEditorFeature.State(), reducer: MemoEditorFeature())
            )
        }
    }
}

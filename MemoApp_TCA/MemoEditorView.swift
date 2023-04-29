//
//  MemoEditorView.swift
//  MemoApp_TCA
//
//  Created by 이은재 on 2023/04/29.
//

import SwiftUI
import RealmSwift

enum Mode {
    case add, update
}

struct MemoEditorView: View {
    @Environment(\.dismiss) var dismiss
    @State var text = ""
    @State var color = Constant.blue
    let placeHolder = "내용을 입력해주세요"
    
    var mode: Mode = .add
    var memo: Memo?
    var addMemo: (Memo) -> Void = {_ in}
    var updateMemo: (_ id: ObjectId, _ text: String, _ color: String) -> Void = { _,_,_ in }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(color)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $text)
                        .font(.body)
                        .foregroundColor(Color(.white))
                        .disableAutocorrection(true)
                        .submitLabel(.done)
                        .scrollContentBackground(.hidden)
                        .padding()
                    
                    if(text.isEmpty) {
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
                        .frame(width: color == Constant.blue ? 60 : 50, height: color == Constant.blue ? 60 : 50)
                        .foregroundColor(Color(Constant.blue))
                        .overlay {
                            Circle()
                                .stroke(lineWidth: 2)
                                .foregroundColor(Color.white)
                        }
                        .onTapGesture {
                            withAnimation {
                                self.color = Constant.blue
                            }
                        }
                    Circle()
                        .frame(width: color == Constant.pink ? 60 : 50, height: color == Constant.pink ? 60 : 50)
                        .foregroundColor(Color(Constant.pink))
                        .overlay {
                            Circle()
                                .stroke(lineWidth: 2)
                                .foregroundColor(Color.white)
                        }
                        .onTapGesture {
                            withAnimation {
                                self.color = Constant.pink
                            }
                        }
                    Circle()
                        .frame(width: color == Constant.green ? 60 : 50, height: color == Constant.green ? 60 : 50)
                        .foregroundColor(Color(Constant.green))
                        .overlay {
                            Circle()
                                .stroke(lineWidth: 2)
                                .foregroundColor(Color.white)
                        }
                        .onTapGesture {
                            withAnimation {
                                self.color = Constant.green
                            }
                        }
                    Circle()
                        .frame(width: color == Constant.purple ? 60 : 50, height: color == Constant.purple ? 60 : 50)
                        .foregroundColor(Color(Constant.purple))
                        .overlay {
                            Circle()
                                .stroke(lineWidth: 2)
                                .foregroundColor(Color.white)
                        }
                        .onTapGesture {
                            withAnimation {
                                self.color = Constant.purple
                            }
                        }
                }
            }
        }
        .toolbar {
            if mode == .add {
                Button {
                    let memo = Memo(value: [
                        "text": self.text,
                        "color": self.color
                    ])
                    addMemo(memo)
                    dismiss()
                } label: {
                    Text("저장하기")
                        .foregroundColor(.white)
                }
            } else {
                Button {
                    if let memo = memo {
                        updateMemo(memo.id, text, color)
                    }
                    dismiss()
                } label: {
                    Text("수정완료")
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            if let memo = memo {
                self.text = memo.text
                self.color = memo.color
            }
        }
        .navigationBarTitleDisplayMode(.inline)

    }
}

struct MemoEditorView_Previews: PreviewProvider {
    static var previews: some View {
        MemoEditorView()
    }
}

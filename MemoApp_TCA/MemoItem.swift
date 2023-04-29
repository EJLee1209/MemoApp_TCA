//
//  MemoItem.swift
//  MemoApp_TCA
//
//  Created by 이은재 on 2023/04/29.
//

import SwiftUI

struct MemoItem: View {
    var memo: Memo
    
    init(_ memo: Memo) {
        self.memo = memo
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(memo.text)
                    .font(.system(size: 20))
                    .bold()
                    .lineLimit(1)
                Text(memo.date, style: .date)
                    .font(.system(size: 16))
                    .padding(.top, 12)
            }
            Spacer()
        }
        .padding()
        .background(Color(memo.color))
        .cornerRadius(15)
    }
}

struct MemoItem_Previews: PreviewProvider {
    static var previews: some View {
        MemoItem(Memo(value: [
            "text" : "hello world"
        ]))
    }
}

//
//  RadioButton.swift
//  MemoApp_TCA
//
//  Created by 이은재 on 2023/05/07.
//

import SwiftUI
import ComposableArchitecture

////MARK: - ReducerProtocol을 따르는 RadioFeature
struct RadioFeature: ReducerProtocol {
    struct State: Equatable {
        var selected = 0
    }
    enum Action: Equatable {
        case changeSelection(idx: Int)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .changeSelection(idx):
            state.selected = idx
            return .none
        }
    }
}


////MARK: - RadioButton View
struct RadioButton: View {
    let store: StoreOf<RadioFeature>
    var values: [String]
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    HStack(alignment: .center, spacing:0) {
                        
                        ForEach(values.indices) { index in
                            Button {
                                viewStore.send(.changeSelection(idx: index))
                            } label: {
                                Text(values[index])
                                    .foregroundColor(Color("title_color"))
                                    .lineLimit(1)
                                    .frame(width: getButtonWidth(proxy: proxy))
                                    
                            }
                            if index-1 != values.count {
                                Divider()
                            }
                        }
                    }
                    .frame(maxHeight: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color("lightGray"))
                    .cornerRadius(15)
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: getButtonWidth(proxy: proxy), height: 50)
                        .opacity(0.1)
                        .offset(x: CGFloat(viewStore.selected)*getButtonWidth(proxy: proxy))
                        .animation(.default, value: viewStore.selected)
                }
            }
            .frame(height: 50)
        }
    }
    
    func getButtonWidth(proxy: GeometryProxy) -> CGFloat {
        return proxy.size.width / CGFloat(self.values.count)
    }
}

struct RadioButton_Previews: PreviewProvider {
    static var previews: some View {
        RadioButton(
            store: Store(
                initialState: RadioFeature.State(),
                reducer: RadioFeature()),
            values: [
                "오름차순",
                "내림차순"
            ]
        )
    }
}

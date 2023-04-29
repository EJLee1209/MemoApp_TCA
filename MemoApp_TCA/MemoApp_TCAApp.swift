//
//  MemoApp_TCAApp.swift
//  MemoApp_TCA
//
//  Created by 이은재 on 2023/04/29.
//

import SwiftUI
import ComposableArchitecture

@main
struct MemoApp_TCAApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store(initialState: MemoFeature.MemoState(), reducer: MemoFeature())
            )
        }
    }
}

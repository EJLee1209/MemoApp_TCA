//
//  Memo.swift
//  MemoApp_TCA
//
//  Created by 이은재 on 2023/04/29.
//

import Foundation
import RealmSwift
import SwiftUI

class Memo: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var text: String = ""
    @Persisted var date: Date = Date.now
    @Persisted var color: String = "blue"
}

struct Constant {
    static let blue = "blue"
    static let yellow = "yellow"
    static let pink = "pink"
    static let purple = "purple"
    static let green = "green"
}

//
// Created by 和泉田 領一 on 2017/09/07.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import Foundation

struct TopicItem: FeedbackUnit {
    let topics: [any TopicProtocol]

    var title: String? {
        selection?.localizedTitle
    }

    let selection: (any TopicProtocol)?

    let display: Bool

    init(_ topics: [any TopicProtocol], selection: (any TopicProtocol)? = nil) {
        self.topics = topics
        display = !topics.isEmpty
        self.selection = selection ?? topics.first
    }
}

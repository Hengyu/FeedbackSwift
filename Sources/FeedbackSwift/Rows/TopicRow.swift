//
//  TopicRow.swift
//  FeedbackSwift
//

import SwiftUI

struct TopicRow: View {
    @Bindable var viewModel: FeedbackViewModel

    var body: some View {
        HStack {
            Text(localized("feedback.Topic"))
            Spacer()
            Menu {
                ForEach(viewModel.topics, id: \.title) { topic in
                    Button {
                        viewModel.selectedTopic = topic
                    } label: {
                        if topic.title == viewModel.selectedTopic?.title {
                            Label(topic.localizedTitle, systemImage: "checkmark")
                        } else {
                            Text(topic.localizedTitle)
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(viewModel.selectedTopic?.localizedTitle ?? "")
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

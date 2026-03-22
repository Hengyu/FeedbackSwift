//
//  BodyRow.swift
//  FeedbackSwift
//

import SwiftUI

struct BodyRow: View {
    @Bindable var viewModel: FeedbackViewModel

    var body: some View {
        #if os(tvOS)
        TextField(localized("feedback.BodyPlaceholder"), text: $viewModel.bodyText, axis: .vertical)
            .lineLimit(5...20)
        #else
        ZStack(alignment: .topLeading) {
            if viewModel.bodyText.isEmpty {
                Text(localized("feedback.BodyPlaceholder"))
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                    .padding(.leading, 5)
                    .allowsHitTesting(false)
            }
            TextEditor(text: $viewModel.bodyText)
                .frame(minHeight: 100)
                .scrollContentBackground(.hidden)
        }
        #endif
    }
}

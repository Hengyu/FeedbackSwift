//
//  UserEmailRow.swift
//  FeedbackSwift
//

import SwiftUI

struct UserEmailRow: View {
    @Bindable var viewModel: FeedbackViewModel

    var body: some View {
        TextField(localized("feedback.Mail"), text: $viewModel.userEmail)
            #if os(iOS) || targetEnvironment(macCatalyst)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            #endif
            .autocorrectionDisabled()
    }
}

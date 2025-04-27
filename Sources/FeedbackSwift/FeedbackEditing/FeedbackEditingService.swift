//
// Created by 和泉田 領一 on 2017/09/09.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import Foundation

@MainActor public protocol FeedbackEditingEventProtocol {
    func updated(at indexPath: IndexPath)
}

@MainActor public protocol FeedbackEditingServiceProtocol {
    var topics: [any TopicProtocol] { get }
    var hasAttachedMedia: Bool { get }

    func update(userEmailText: String?)
    func update(bodyText: String?)
    func update(selectedTopic: any TopicProtocol)
    func update(attachmentMedia: Media?)
    func generateFeedback(configuration: FeedbackConfiguration) -> Feedback
}

public final class FeedbackEditingService {
    var editingItemsRepository: FeedbackEditingItemsRepositoryProtocol
    let feedbackEditingEventHandler: FeedbackEditingEventProtocol

    public init(
        editingItemsRepository: FeedbackEditingItemsRepositoryProtocol,
        feedbackEditingEventHandler: FeedbackEditingEventProtocol
    ) {
        self.editingItemsRepository = editingItemsRepository
        self.feedbackEditingEventHandler = feedbackEditingEventHandler
    }
}

extension FeedbackEditingService: FeedbackEditingServiceProtocol {
    public var topics: [any TopicProtocol] {
        guard let item = editingItemsRepository.item(of: TopicItem.self) else { return [] }
        return item.topics
    }

    public var hasAttachedMedia: Bool {
        guard let item = editingItemsRepository.item(of: AttachmentItem.self) else { return false }
        return item.media != .none
    }

    public func update(userEmailText: String?) {
        guard var item = editingItemsRepository.item(of: UserEmailItem.self) else { return }
        item.email = userEmailText
        editingItemsRepository.set(item)
    }

    public func update(bodyText: String?) {
        guard let item = editingItemsRepository.item(of: BodyItem.self) else { return }

        let newItem = BodyItem(display: item.display, bodyText: bodyText)
        editingItemsRepository.set(newItem)
    }

    public func update(selectedTopic: any TopicProtocol) {
        guard let item = editingItemsRepository.item(of: TopicItem.self) else { return }

        let newItem = TopicItem(item.topics, selection: selectedTopic)
        guard let indexPath = editingItemsRepository.set(newItem) else { return }
        feedbackEditingEventHandler.updated(at: indexPath)
    }

    public func update(attachmentMedia: Media?) {
        guard let item = editingItemsRepository.item(of: AttachmentItem.self) else { return }

        let newItem = AttachmentItem(display: item.display, media: attachmentMedia)
        guard let indexPath = editingItemsRepository.set(newItem) else { return }
        feedbackEditingEventHandler.updated(at: indexPath)
    }

    public func generateFeedback(configuration: FeedbackConfiguration) -> Feedback {
        FeedbackGenerator.generate(
            configuration: configuration,
            repository: editingItemsRepository
        )
    }
}

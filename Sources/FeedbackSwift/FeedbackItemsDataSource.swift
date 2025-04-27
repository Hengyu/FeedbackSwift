//
// Created by 和泉田 領一 on 2017/09/07.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import UIKit

public struct FeedbackUnitPreference: Equatable, Hashable, Sendable {
    public let enablesUserEmail: Bool
    public let enablesAttachment: Bool
    public let enablesCameraPicker: Bool
    public let showsAppInfo: Bool

    public init(
        enablesUserEmail: Bool = false,
        enablesAttachment: Bool = true,
        enablesCameraPicker: Bool = false,
        showsAppInfo: Bool = false
    ) {
        self.enablesUserEmail = enablesUserEmail
        self.enablesAttachment = enablesAttachment
        self.enablesCameraPicker = enablesCameraPicker
        self.showsAppInfo = showsAppInfo
    }

    public static let `default`: FeedbackUnitPreference = .init()
}

public final class FeedbackItemsDataSource: Equatable, @unchecked Sendable {

    public let sections: [FeedbackItemsSection]

    public static func == (lhs: FeedbackItemsDataSource, rhs: FeedbackItemsDataSource) -> Bool {
        lhs.sections == rhs.sections
    }

    var numberOfSections: Int {
        filteredSections.count
    }

    private(set) var filteredSections: [FeedbackItemsSection]

    public init(
        topics: [any TopicProtocol],
        preference: FeedbackUnitPreference = .default
    ) {
        var sections = [FeedbackItemsSection]()
        sections.append(
            FeedbackItemsSection(
                title: localized("feedback.UserDetail"),
                items: [UserEmailItem(display: preference.enablesUserEmail)]
            )
        )
        sections.append(
            FeedbackItemsSection(items: [TopicItem(topics), BodyItem()])
        )
        sections.append(
            FeedbackItemsSection(
                title: localized("feedback.AdditionalInfo"),
                items: [AttachmentItem(display: preference.enablesAttachment)]
            )
        )
        sections.append(
            FeedbackItemsSection(
                title: localized("feedback.DeviceInfo"),
                items: [DeviceNameItem(), SystemVersionItem()]
            )
        )
        sections.append(
            FeedbackItemsSection(
                title: localized("feedback.AppInfo"),
                items: [
                    AppNameItem(display: preference.showsAppInfo),
                    AppVersionItem(display: preference.showsAppInfo),
                    AppBuildItem(display: preference.showsAppInfo),
                ]
            )
        )

        self.sections = sections

        filteredSections = sections.filter { section in
            !section.items.filter { $0.display }.isEmpty
        }
    }

    func section(at section: Int) -> FeedbackItemsSection {
        filteredSections[section]
    }
}

extension FeedbackItemsDataSource {
    private subscript(indexPath: IndexPath) -> any FeedbackUnit {
        get { filteredSections[indexPath.section][indexPath.item] }
        set { filteredSections[indexPath.section][indexPath.item] = newValue }
    }

    private func indexPath<Item>(of type: Item.Type) -> IndexPath? {
        let filtered = filteredSections
        for section in filtered {
            guard let index = filtered.firstIndex(where: { $0 == section }),
                  let subIndex = section.items.firstIndex(where: { $0 is Item })
            else { continue }
            return IndexPath(item: subIndex, section: index)
        }
        return .none
    }
}

extension FeedbackItemsDataSource: FeedbackEditingItemsRepositoryProtocol {
    public func item<Item>(of type: Item.Type) -> Item? {
        guard let indexPath = indexPath(of: type) else { return nil }
        return self[indexPath] as? Item
    }

    @discardableResult
    public func set<Item: FeedbackUnit>(_ item: Item) -> IndexPath? {
        guard let indexPath = indexPath(of: Item.self) else { return nil }
        self[indexPath] = item
        return indexPath
    }
}

public struct FeedbackItemsSection: Equatable, Sendable {
    public let title: String?
    public var items: [any FeedbackUnit]

    public init(title: String? = nil, items: [any FeedbackUnit]) {
        self.title = title
        self.items = items
    }

    public static func == (lhs: FeedbackItemsSection, rhs: FeedbackItemsSection) -> Bool {
        lhs.title == rhs.title &&
        lhs.items.count == rhs.items.count &&
        lhs.enumerated().allSatisfy { offset, item in
            item.id == rhs.items[offset].id
        }
    }
}

extension FeedbackItemsSection: Collection {
    public var startIndex: Int { items.startIndex }
    public var endIndex: Int { items.endIndex }

    public subscript(position: Int) -> any FeedbackUnit {
        get { items[position] }
        set { items[position] = newValue }
    }

    public func index(after index: Int) -> Int { items.index(after: index) }
}

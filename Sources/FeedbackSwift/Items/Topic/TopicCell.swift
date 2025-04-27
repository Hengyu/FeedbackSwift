//
// Created by 和泉田 領一 on 2017/09/07.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import UIKit

@MainActor protocol TopicCellProtocol {
    func topicCellOptionChanged(_ option: any TopicProtocol)
}

final public class TopicCell: UITableViewCell {
    private let button: UIButton = .init(type: .system)

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: TopicCell.reuseIdentifier)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.showsMenuAsPrimaryAction = true
        accessoryView = button
        heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
    }
}

extension TopicCell: CellFactoryProtocol {
    static func configure(
        _ cell: TopicCell,
        with item: TopicItem,
        for indexPath: IndexPath,
        eventHandler: TopicCellProtocol?
    ) {
        cell.textLabel?.text = localized("feedback.Topic")
        cell.button.setTitle(item.title, for: .normal)
        cell.button.menu = .init(
            children: item.topics.map { topic in
                UIAction(title: topic.localizedTitle) { _ in
                    eventHandler?.topicCellOptionChanged(topic)
                }
            }
        )
        cell.button.sizeToFit()
        cell.selectionStyle = .none
    }
}

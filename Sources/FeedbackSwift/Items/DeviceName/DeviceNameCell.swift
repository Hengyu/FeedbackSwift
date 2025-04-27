//
//  DeviceNameCell.swift
//  CTFeedbackSwift
//
//  Created by 和泉田 領一 on 2017/09/24.
//  Copyright © 2017 CAPH TECH. All rights reserved.
//

import UIKit

final class DeviceNameCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
    }
}

extension DeviceNameCell: CellFactoryProtocol {
    static let reuseIdentifier: String = "DeviceNameCell"

    static func configure(
        _ cell: DeviceNameCell,
        with item: DeviceNameItem,
        for indexPath: IndexPath,
        eventHandler: Any?
    ) {
        cell.textLabel?.text = localized("feedback.Device")
        cell.detailTextLabel?.text = item.name
        cell.selectionStyle = .none
    }
}

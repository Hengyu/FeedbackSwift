//
//  SystemVersionCell.swift
//  CTFeedbackSwift
//
//  Created by 和泉田 領一 on 2017/09/24.
//  Copyright © 2017 CAPH TECH. All rights reserved.
//

import UIKit

final class SystemVersionCell: UITableViewCell {
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
    }
}

extension SystemVersionCell: CellFactoryProtocol {
    class func configure(
        _ cell: SystemVersionCell,
        with item: SystemVersionItem,
        for indexPath: IndexPath,
        eventHandler: Any?
    ) {
        #if os(macOS) || targetEnvironment(macCatalyst)
        cell.textLabel?.text = "macOS"
        #elseif os(iOS)
        cell.textLabel?.text = "iOS"
        #elseif os(visionOS)
        cell.textLabel?.text = "visionOS"
        #endif
        cell.detailTextLabel?.text = item.version
        cell.selectionStyle = .none
    }
}

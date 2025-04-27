//
// Created by 和泉田 領一 on 2017/09/07.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import UIKit

@MainActor protocol CellFactoryProtocol {
    associatedtype Item: FeedbackUnit
    associatedtype Cell: UITableViewCell
    associatedtype EventHandler

    static var reuseIdentifier: String { get }

    static func configure(
        _ cell: Cell,
        with item: Item,
        for indexPath: IndexPath,
        eventHandler: EventHandler
    )
}

extension CellFactoryProtocol {
    static var cellType: AnyClass {
        Cell.self
    }

    static var reuseIdentifier: String {
        String(describing: self)
    }

    static func suitable(for item: Any) -> Bool {
        item is Item
    }

    @discardableResult static func configure(
        _ cell: UITableViewCell,
        with item: any FeedbackUnit,
        for indexPath: IndexPath,
        eventHandler: Any?
    ) -> Bool {
        guard
            let cell = cell as? Cell,
            let item = item as? Item,
            let eventHandler = eventHandler as? EventHandler
        else { return false }

        configure(cell, with: item, for: indexPath, eventHandler: eventHandler)

        return true
    }
}

@MainActor public final class AnyCellFactory {
    private let factory: any CellFactoryProtocol.Type

    var cellType: AnyClass {
        factory.cellType
    }

    var reuseIdentifier: String {
        factory.reuseIdentifier
    }

    init<Factory: CellFactoryProtocol>(_ cellFactory: Factory.Type) {
        factory = cellFactory
    }

    func suitable(for item: Any) -> Bool { factory.suitable(for: item) }

    @discardableResult func configure(
        _ cell: UITableViewCell,
        with item: any FeedbackUnit,
        for indexPath: IndexPath,
        eventHandler: Any?
    ) -> Bool {
        factory.configure(cell, with: item, for: indexPath, eventHandler: eventHandler)
    }
}

extension UITableView {
    func register(with cellFactory: AnyCellFactory) {
        register(cellFactory.cellType, forCellReuseIdentifier: cellFactory.reuseIdentifier)
    }

    func dequeueCell(
        to item: any FeedbackUnit,
        from cellFactories: [AnyCellFactory],
        for indexPath: IndexPath,
        filter: (Any, [AnyCellFactory]) -> AnyCellFactory? = { item, factories in
            factories.first { $0.suitable(for: item) }
        },
        eventHandler: Any?
    ) -> UITableViewCell {
        guard let cellFactory = filter(item, cellFactories) else { fatalError() }
        let cell = dequeueReusableCell(withIdentifier: cellFactory.reuseIdentifier, for: indexPath)
        cellFactory.configure(cell, with: item, for: indexPath, eventHandler: eventHandler)
        return cell
    }
}

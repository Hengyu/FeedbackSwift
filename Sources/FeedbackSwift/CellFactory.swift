//
// Created by 和泉田 領一 on 2017/09/07.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import UIKit

protocol CellFactoryProtocol {
    associatedtype Item
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
    static var reuseIdentifier: String { String(describing: self) }

    static func suitable(for item: Any) -> Bool { item is Item }

    static func configure(

        _ cell: UITableViewCell,
        with item: Any,
        for indexPath: IndexPath,
        eventHandler: Any?
    ) -> UITableViewCell? {
            guard
                let cell = cell as? Cell,
                let item = item as? Item,
                let eventHandler = eventHandler as? EventHandler
            else { return .none }
            configure(cell, with: item, for: indexPath, eventHandler: eventHandler)
            return cell
        }
}

public class AnyCellFactory {
    let cellType: AnyClass
    let reuseIdentifier: String
    private let suitableClosure: (Any) -> Bool
    private let configureCellClosure: (UITableViewCell, Any, IndexPath, Any?) -> UITableViewCell?

    init<Factory: CellFactoryProtocol>(_ cellFactory: Factory.Type) {
        cellType = Factory.Cell.self
        reuseIdentifier = cellFactory.reuseIdentifier
        suitableClosure = cellFactory.suitable(for:)
        configureCellClosure = cellFactory.configure(_:with:for:eventHandler:)
    }

    func suitable(for item: Any) -> Bool { suitableClosure(item) }

    func configure(
        _ cell: UITableViewCell,
        with item: Any,
        for indexPath: IndexPath,
        eventHandler: Any?
    ) -> UITableViewCell? {
        configureCellClosure(cell, item, indexPath, eventHandler)
    }
}

extension UITableView {
    func register(with cellFactory: AnyCellFactory) {
        register(cellFactory.cellType, forCellReuseIdentifier: cellFactory.reuseIdentifier)
    }

    func dequeueCell(
        to item: Any,
        from cellFactories: [AnyCellFactory],
        for indexPath: IndexPath,
        filter: (Any, [AnyCellFactory]) -> AnyCellFactory? = cellFactoryFilter,
        eventHandler: Any?
    ) -> UITableViewCell {
        guard let cellFactory = filter(item, cellFactories) else { fatalError() }
        let cell = dequeueReusableCell(withIdentifier: cellFactory.reuseIdentifier, for: indexPath)
        guard let configured = cellFactory.configure(
            cell,
            with: item,
            for: indexPath,
            eventHandler: eventHandler
        )
        else { fatalError() }
        return configured
    }
}

let cellFactoryFilter: (Any, [AnyCellFactory]) -> AnyCellFactory? = { item, factories in
    factories.first { $0.suitable(for: item) }
}

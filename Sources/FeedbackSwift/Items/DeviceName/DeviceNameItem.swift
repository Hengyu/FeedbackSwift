//
// Created by 和泉田 領一 on 2017/09/24.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import Foundation

struct DeviceNameItem: FeedbackUnit {
    let display: Bool

    var name: String? {
        guard
            let path = Bundle.platformNamesPlistPath,
            let dictionary = NSDictionary(contentsOfFile: path) as? [String: String],
            let platform = getPlatform()
        else { return nil }

        return dictionary[platform] ?? platform
    }

    init(display: Bool = true) {
        self.display = display
    }

    private func getPlatform() -> String? {
        var systemInfo = utsname()
        uname(&systemInfo)
        guard let machine = withUnsafePointer(to: &systemInfo.machine, {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) { ptr in
                String(validatingCString: ptr)
            }
        }) else { return nil }

        return machine
    }
}

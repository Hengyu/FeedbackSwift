//
// Created by 和泉田 領一 on 2017/09/24.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import Foundation

struct DeviceNameItem {
    static var name: String? {
        guard
            let path = Bundle.platformNamesPlistPath,
            let dictionary = NSDictionary(contentsOfFile: path) as? [String: String],
            let platform = platform
        else { return nil }

        return dictionary[platform] ?? platform
    }

    private static var platform: String? {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) { ptr in
                String(validatingCString: ptr)
            }
        }
    }
}

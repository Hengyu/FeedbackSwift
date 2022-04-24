//
// Created by 和泉田 領一 on 2017/09/18.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import UIKit

struct AttachmentItem: FeedbackItemProtocol {
    var attached: Bool {
        media != nil
    }
    var media: Media?
    var image: UIImage? {
        switch media {
        case .image(let image)?:    return image
        case .video(let image, _)?: return image
        default: return nil
        }
    }
    let isHidden: Bool

    init(isHidden: Bool) {
        self.isHidden = isHidden
    }
}

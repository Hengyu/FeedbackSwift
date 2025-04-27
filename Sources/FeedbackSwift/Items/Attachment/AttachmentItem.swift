//
// Created by 和泉田 領一 on 2017/09/18.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import UIKit

struct AttachmentItem: FeedbackUnit {
    var isAttached: Bool {
        media != nil
    }

    var image: UIImage? {
        switch media {
        case .image(let image):
            return image
        case .video(let image, _):
            return image
        default: return nil
        }
    }

    let display: Bool
    let media: Media?

    init(display: Bool, media: Media? = nil) {
        self.display = display
        self.media = media
    }
}

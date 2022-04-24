# FeedbackSwift

FeedbackSwift is a framework to compose a feedback for iOS 10.0+ & macCatalyst 13.0+.

## Installation

`FeedbackSwift` could be installed via [Swift Package Manager](https://www.swift.org/package-manager/). Open Xcode and go to **File** -> **Add Packages...**, search `https://github.com/hengyu/FeedbackSwift.git`, and add the package as one of your project's dependency.

## How to use

```swift
let configuration = FeedbackConfiguration(toRecipients: ["test@example.com"], usesHTML: true)
let controller = FeedbackViewController(configuration: configuration)
navigationController?.pushViewController(controller, animated: true)
```

## Acknowledgements

The original version of `FeedbackSwift` is [CTFeedbackSwift](https://github.com/rizumita/CTFeedbackSwift), since its not updated for a while, we made the fork version [FeedbackSwift](https://github.com/hengyu/FeedbackSwift).

## License

FeedbackSwift is released under the [MIT License](LICENSE).

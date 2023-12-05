# FeedbackSwift

![](https://img.shields.io/badge/iOS-13.0%2B-green)
![](https://img.shields.io/badge/macCatalyst-13.0%2B-green)
![](https://img.shields.io/badge/Swift-5-orange?logo=Swift&logoColor=white)
![](https://img.shields.io/github/last-commit/hengyu/FeedbackSwift)

**FeedbackSwift** provides an interface to collect user's feedback.

## Table of contents

* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [Acknowledgements](#acknowledgements)
* [License](#license)

## Requirements

- iOS 14.0+, macCatalyst 14.0+

## Installation

`FeedbackSwift` could be installed via [Swift Package Manager](https://www.swift.org/package-manager/). Open Xcode and go to **File** -> **Add Packages...**, search `https://github.com/hengyu/FeedbackSwift.git`, and add the package as one of your project's dependency.

## Usage

```swift
let configuration = FeedbackConfiguration(toRecipients: ["test@example.com"], usesHTML: true)
let controller = FeedbackViewController(configuration: configuration)
navigationController.pushViewController(controller, animated: true)
```

## Acknowledgements

**FeedbackSwift** is originated from the [CTFeedbackSwift](https://github.com/rizumita/CTFeedbackSwift) created by [rizumita](https://github.com/rizumita). We have made several updates based on the original work. And we want to express our heartful appreciation to the creator and contributers of **CTFeedbackSwift**.

## License

[FeedbackSwift](https://github.com/hengyu/FeedbackSwift) is released under the [MIT License](LICENSE).

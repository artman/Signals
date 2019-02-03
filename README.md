# Signals
[![Build Status](https://travis-ci.org/artman/Signals.svg?branch=master)](https://travis-ci.org/artman/Signals)
[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/Signals.svg)](https://cocoapods.org/pods/Signals)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![License](https://img.shields.io/cocoapods/l/Signals.svg?style=flat&color=gray)
![Platform](https://img.shields.io/cocoapods/p/Signals.svg?style=flat)
[![Twitter](https://img.shields.io/badge/twitter-@artman-blue.svg?style=flat)](http://twitter.com/artman)

Signals is a library for creating and observing events. It replaces delegates, actions and NSNotificationCenter with something much more powerful and elegant.

## Features

- [x] Attach-and-forget observation
- [x] Type-safety
- [x] Filtered observation
- [x] Delayed and queued observation
- [x] Comprehensive Unit Test Coverage

## Requirements

- iOS 7.0 / watchOS 2.0 / Mac OS X 10.9
- Swift 4.2

## Installation

To use Signals with a project targeting iOS 7, simply copy `Signals.swift` into your project.

#### CocoaPods

To integrate Signals into your project add the following to your `Podfile`:

```ruby
platform :ios, '8.0'
use_frameworks!

pod 'Signals', '~> 6.0'
```

#### Carthage

To integrate Signals into your project using Carthage add the following to your `Cartfile`:

```ruby
github "artman/Signals" ~> 6.0
```

#### Swift Package Manager

To integrate Signals into your project using SwiftPM add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/artman/Signals", from: "6.0.0"),
],
```

## Quick start

Make events on a class observable by creating one or more signals:

```swift
class NetworkLoader {

    // Creates a number of signals that can be subscribed to
    let onData = Signal<(data:NSData, error:NSError)>()
    let onProgress = Signal<Float>()

    ...

    func receivedData(receivedData:NSData, receivedError:NSError) {
        // Whenever appropriate, fire off any of the signals
        self.onProgress.fire(1.0)
        self.onData.fire((data:receivedData, error:receivedError))
    }
}
```

Subscribe to these signals from elsewhere in your application

```swift
let networkLoader = NetworkLoader("http://artman.fi")

networkLoader.onProgress.subscribe(with: self) { (progress) in
    print("Loading progress: \(progress*100)%")
}

networkLoader.onData.subscribe(with: self) { (data, error) in
    // Do something with the data
}
```

Adding subscriptions to Signals is an attach-and-forget operation. If the subscribing object is deallocated, the `Signal` cancels the subscription, so you don't need to explicitly manage the cancellation of your subsciptions.

Singals aren't restricted to one subscriber. Multiple objects can subscribe to the same Signal.

You can also subscribe to events after they have occurred:

```swift
networkLoader.onProgress.subscribePast(with: self) { (progress) in
    // This will immediately fire with last progress that was reported
    // by the onProgress signal
    println("Loading progress: \(progress*100)%")
}
```

### Advanced topics

Signal subscriptions can apply filters:

```swift
networkLoader.onProgress.subscribe(with: self) { (progress) in
    // This fires when progress is done
}.filter { $0 == 1.0 }
```

You can sample up subscriptions to throttle how often you're subscription is executed, regardless how often the `Signal` fires:

```swift
networkLoader.onProgress.subscribe(with: self) { (progress) in
    // Executed once per second while progress changes
}.sample(every: 1.0)
```

By default, a subscription executes synchronously on the thread that fires the `Signal`. To change the default behaviour, you can use the `dispatchOnQueue` method to define the dispatch queue:

```swift
networkLoader.onProgress.subscribe(with: self) { (progress) in
    // This fires on the main queue
}.dispatchOnQueue(DispatchQueue.main)
```

If you don't like the double quotes when you fire signals that take tuples, you can use the custom `=>` operator to fire the data:

```swift
// If you don't like the double quotes when firing signals that have tuples
self.onData.fire((data:receivedData, error:receivedError))

// You can use the => operator to fire the signal
self.onData => (data:receivedData, error:receivedError)

// Also works for signals without tuples
self.onProgress => 1.0
```

## Replacing actions

Signals extends all classes that extend from UIControl (not available on OS X) and lets you use Signals to listen to control events for increased code locality.

```swift
let button = UIButton()
button.onTouchUpInside.observe(with: self) {
    // Handle the touch
}

let slider = UISlider()
slider.onValueChanged.observe(with: self) {
    // Handle value change
}
```

## Replacing delegates

Signals is simple and modern and greatly reduce the amount of boilerplate that is required to set up delegation.

Would you rather implement a callback using a delegate:

- Create a protocol that defines what is delegated
- Create a delegate property on the class that wants to provide delegation
- Mark each class that wants to become a delegate as comforming to the delegate protocol
- Implement the delegate methods on the class that want to become a delegate
- Set the delegate property to become a delegate of the instance
- Check that your delegate implements each delegate method before invoking it

Or do the same thing with Signals:

- Create a Signal for the class that wants to provide an event
- Subscribe to the Signal

## Replace NotificationCenter

When your team of engineers grows, NotificationCenter quickly becomes an anti-pattern. Global notifications with implicit data and no compiler safety easily make your code error-prone and hard to maintain and refactor.

Replacing NotificationCenter with Signals will give you strong type safety enforced by the compiler that will help you maintain your code no matter how fast you move.

## Communication

- If you **found a bug**, open an issue or submit a fix via a pull request.
- If you **have a feature request**, open an issue or submit a implementation via a pull request or hit me up on Twitter [@artman](http://twitter.com/artman)
- If you **want to contribute**, submit a pull request onto the master branch.

## License

Signals is released under an MIT license. See the LICENSE file for more information

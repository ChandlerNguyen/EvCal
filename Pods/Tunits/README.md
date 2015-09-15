# Tunits

[![CI Status](http://img.shields.io/travis/Thomas Leu/Tunits.svg?style=flat)](https://travis-ci.org/Thomas Leu/Tunits)
[![Version](https://img.shields.io/cocoapods/v/Tunits.svg?style=flat)](http://cocoapods.org/pods/Tunits)
[![License](https://img.shields.io/cocoapods/l/Tunits.svg?style=flat)](http://cocoapods.org/pods/Tunits)
[![Platform](https://img.shields.io/cocoapods/p/Tunits.svg?style=flat)](http://cocoapods.org/pods/Tunits)

## Usage

### Example Project ###

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Swift ###
    let tunit = TimeUnit() // init new TimeUnit object
    let daysOfCurrentMonth = tunit.daysOfMonth(NSDate()) // create array of days
    var hoursOfCurrentMonth : [NSDate] = []
    for day in daysOfCurrentMonth { // enumerate over days to create array of hours
      hoursOfCurrentMonth += tunit.hoursOfDay(day)
    }

## Requirements

Requires XCode 6 and iOS 7+ sdk.

## Installation

Tunits is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Tunits"
```

## Author

Thomas Leu, tomleu@gmail.com

## License

Tunits is available under the MIT license. See the LICENSE file for more info.

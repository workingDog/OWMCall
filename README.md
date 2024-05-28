# Swift OpenWeather Current Weather Data API library

**OWMCall** is a small Swift library to connect to the [OpenWeather Current Weather Data API](https://openweathermap.org/api#current) and retrieve the chosen weather data. Made easy to use with **SwiftUI**.

The library provides for **current** data through a single function call.

### Usage

Weather data from [OpenWeather Current Weather Data API](https://openweathermap.org/api#current) is accessed through the use of a **OWMProvider**, with a single function **getWeather**, eg:

```swift
let weatherProvider = OWMProvider(apiKey: "your key") // default Current Weather API 2.5
@State var weather = OWMResponse()
...

Alternatively;

let weatherProvider = OWMProvider(apiKey: "your key", urlString: "https://api.openweathermap.org/data/2.5/weather")  


// using a binding
weatherProvider.getWeather(lat: 35.661991, lon: 139.762735, weather: $weather)
...
Text(weather.current?.weatherInfo() ?? "")

// or using the async style, eg with `.task {...}`
if let results = await weatherProvider.getWeather(lat: 35.661991, lon: 139.762735) {
        weather = results
}

// or using the callback style, eg with `.onAppear {...}`
weatherProvider.getWeather(lat: 35.661991, lon: 139.762735) { response in
       if let theWeather = response {
          self.weather = theWeather
       }
}
```

See the following for example uses:

-   [*OWMCallExample*](https://github.com/workingDog/OWMCallExample)


### Options

Options available:

-   see [OpenWeather Current Weather Data API](https://openweathermap.org/current) for all the options available.

Default options in the `getWeather(...)` call, is metric with the current local language.

Create a custom options object such as this, to retrieve the current weather data:

```swift
let myOptions = OWMOptions(units: .metric, lang: "en")

weatherProvider.getWeather(lat: 35.661991, lon: 139.762735, weather: $weather, options: myOptions)
```

### Installation

Include the files in the **./Sources/OWMCall** folder into your project or preferably use **Swift Package Manager**.

#### Swift Package Manager  (SPM)

Create a Package.swift file for your project and add a dependency to:

```swift
dependencies: [
  .package(url: "https://github.com/workingDog/OWMCall.git", from: "1.0.0")
]
```

#### Using Xcode

    Select your project > Swift Packages > Add Package Dependency...
    https://github.com/workingDog/OWMCall.git

Then in your code:

```swift
import OWMCall
```
    
### References

-    [OpenWeather Current Weather Data API](https://openweathermap.org/api#current)


### Requirement

Requires a valid OpenWeather key, see:

-    [OpenWeather how to start](https://openweathermap.org/appid)

### License

MIT

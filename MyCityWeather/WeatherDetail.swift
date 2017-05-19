//
//  WeatherDetail.swift
//  MyCityWeather
//  This class represents the temperature units, number of results
// and the class to represent the weather detail
//

import UIKit

/**
 This class stores the temperature unit values
 **/

public class TempUnit {
    
    static let count = 2
    
    var value: TemperatureUnitValue
    
    init(value: TemperatureUnitValue) {
        self.value = value
    }
    
    convenience init(rawValue: Int) {
        self.init(value: TemperatureUnitValue(rawValue: rawValue)!)
    }
    
    enum TemperatureUnitValue: Int {
        case celsius
        case fahrenheit
    }
    
    
    var stringValue: String {
        switch value {
        case .celsius: return "Celsius"
        case .fahrenheit: return "Fahrenheit"
        }
    }
}

/**
 Class to store the number of results to display for surrounding locations
 **/
public class numberResults {
    
    static let count = 10
    
}

/**
 This class represents the weather details and the URLS to connect to OpenWeather
 and fetch the weather  values based on the locations
 **/
class WeatherDetail: NSObject, NSCoding {
    
    
    public static var current: WeatherDetail!
    
    
    //Open Weather URLS
    private static let openWeather_SingleLocationBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private static let openWeather_MultiLocationBaseURL = "http://api.openweathermap.org/data/2.5/find"
    
    
    // Properties of the Weather Class
    
    //Temperature Units
    public var temperatureUnit: TempUnit {
        didSet {
            WeatherDetail.storeService()
            NotificationCenter.default.post(name: Notification.Name(rawValue: KeyValues.weatherServiceUpdated.rawValue), object: self)
        }
    }
    //Location of My chosen city
    public var myCityLocation: String {
        didSet {
            WeatherDetail.storeService()
            NotificationCenter.default.post(name: Notification.Name(rawValue: KeyValues.weatherServiceUpdated_dataPullRequired.rawValue), object: self)
        }
    }
    //The number of results to display
    public var numberResults: Int {
        didSet {
            WeatherDetail.storeService()
            NotificationCenter.default.post(name: Notification.Name(rawValue: KeyValues.weatherServiceUpdated_dataPullRequired.rawValue), object: self)
        }
    }
    //Weather data for single and multiple locations arrays
    public var singleLocWeatherData: [WeatherData]
    public var multiLocWeatherData: [WeatherData]

    
    // Initialization of the variables
    
    private init(myCityLocation: String, numberResults: Int) {
        self.temperatureUnit = TempUnit(value: .fahrenheit)
        self.myCityLocation = myCityLocation
        self.numberResults = numberResults
        
        self.singleLocWeatherData = [WeatherData]()
        self.multiLocWeatherData = [WeatherData]()
        
        super.init()
    }
    
    //Convenience Initializers
    internal required convenience init?(coder aDecoder: NSCoder) {
        let tempUnit = aDecoder.decodeInteger(forKey: PropertyKey.temperatureUnitKey)
        let myCityLocationKey = aDecoder.decodeObject(forKey: PropertyKey.myCityLocationKey) as! String
        let number = aDecoder.decodeInteger(forKey: PropertyKey.numberResultsKey)
        let singleLocWeatherData = aDecoder.decodeObject(forKey: PropertyKey.singleLocWeatherKey) as! [WeatherData]
        let multiLocWeatherData = aDecoder.decodeObject(forKey: PropertyKey.multiLocWeatherKey) as! [WeatherData]
        
        self.init(myCityLocation: myCityLocationKey, numberResults: number)
        self.temperatureUnit = TempUnit(rawValue: tempUnit)
        self.numberResults = number
        self.singleLocWeatherData = singleLocWeatherData
        self.multiLocWeatherData = multiLocWeatherData
    }
    
    
    // Methods and Properties
    
    public static func attachPersistentObject() {
        if let previousService: WeatherDetail = WeatherDetail.loadService() {
            WeatherDetail.current = previousService
        } else {
            WeatherDetail.current = WeatherDetail(myCityLocation: "Canberra", numberResults: 10)
        }
    }
    
    //Method to fetch data
    public func fetchDataWith(completionHandler: (() -> Void)?) {
        let dataQueue = DispatchQueue(label: "mycity_weather.weather_data_fetch")
        dataQueue.async {
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            self.fetchSingleLocationWeatherData(completionHandler: { data in
                self.singleLocWeatherData = data
                dispatchGroup.leave()
            })
            
            dispatchGroup.enter()
            self.fetchMultiLocationWeatherData(completionHandler: { data in
                self.multiLocWeatherData = data
                dispatchGroup.leave()
            })
            
            dispatchGroup.wait()
            DispatchQueue.main.async(execute: {
                WeatherDetail.storeService()
                NotificationCenter.default.post(name: Notification.Name(rawValue: KeyValues.weatherServiceUpdated.rawValue), object: self)
                completionHandler?()
            })
        }
    }

    

    
   //Storage helper classes
    
    private static func loadService() -> WeatherDetail? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: WeatherDetail.ArchiveURL.path) as? WeatherDetail
    }
    
    private static func storeService() {
        _ = NSKeyedArchiver.archiveRootObject(WeatherDetail.current, toFile: WeatherDetail.ArchiveURL.path)
    }
    
    //Function to fetch the weather data from URL for single location
    
    private func fetchSingleLocationWeatherData(completionHandler: @escaping ([WeatherData]) -> Void) {
        guard let apiKey = UserDefaults.standard.value(forKey: "mycity_weather.openWeatherMapApiKey") else {
            return completionHandler([WeatherData]())
        }
        
        let session = URLSession.shared
        
        let requestedCity: String = self.myCityLocation.replacingOccurrences(of: " ", with: "")
        let requestURL = NSMutableURLRequest(url: URL(string: "\(WeatherDetail.openWeather_SingleLocationBaseURL)?APPID=\(apiKey)&q=\(requestedCity)")!)
        
        let request = session.dataTask(with: requestURL as URLRequest, completionHandler: { (data, response, error) in
            guard let _: Data = data, let _: URLResponse = response  , error == nil else {
                return
            }
            completionHandler(self.processSingleLocation(weatherData: data!))
        })
        request.resume()
    }
    
    //Function to fetch the weather data from URL for multiple locations
    private func fetchMultiLocationWeatherData(completionHandler: @escaping ([WeatherData]) -> Void) {
        guard let apiKey = UserDefaults.standard.value(forKey: "mycity_weather.openWeatherMapApiKey") else {
            return completionHandler([WeatherData]())
        }
        
        let session = URLSession.shared
        
        let requestURL = NSMutableURLRequest(url: URL(string: "\(WeatherDetail.openWeather_MultiLocationBaseURL)?APPID=\(apiKey)&lat=\(LocationDetail.current.currentLatitude)&lon=\(LocationDetail.current.currentLongitude)&cnt=\(numberResults)")!)
        
        let request = session.dataTask(with: requestURL as URLRequest, completionHandler: { (data, response, error) in
            guard let _: Data = data, let _: URLResponse = response  , error == nil else {
                return
            }
            completionHandler(self.processMultiLocation(weatherData: data!))
        })
        request.resume()
        
    }
    
    //Function to process the JSON data received from OPenWeather for single location
    private func processSingleLocation(weatherData json: Data) -> [WeatherData] {
        do {
            let data = try JSONSerialization.jsonObject(with: json, options: .mutableContainers) as! [String: AnyObject]
            
            guard 200 == data["cod"]! as! Int else {
                return [WeatherData]()
            }
            
            let condition = determineWeatherConditionSymbol(fromWeathercode: ((data["weather"] as! NSArray)[0] as! [String: AnyObject])["id"]! as! Int)
            let cityName = data["name"]! as! String
            let rawTemperature = data["main"]!["temp"]!! as! Double
            let cloudCoverage = data["clouds"]!["all"]!! as! Double
            let humidity = data["main"]!["humidity"]!! as! Double
            let windspeed = data["wind"]!["speed"]!! as! Double
            
            return [WeatherData(condition: condition, cityName: cityName, rawTemperature: rawTemperature, cloudCoverage: cloudCoverage, humidity: humidity, windspeed: windspeed)]
        }
        catch let jsonError as NSError {
            print("JSON error description: \(jsonError.description)")
            return [WeatherData]()
        }
    }
    
    //Function to process JSON data received from OpenWeather for multiple locations
    private func processMultiLocation(weatherData json: Data) -> [WeatherData] {
        do {
            let rawData = try JSONSerialization.jsonObject(with: json, options: .mutableContainers) as! [String: AnyObject]
            let extractedData = rawData["list"]! as? [[String: AnyObject]]
            var multiLocationData = [WeatherData]()
            
            guard "200" == rawData["cod"]! as! String else {
                return [WeatherData]()
            }
            
            for entry in extractedData! {
                let condition = determineWeatherConditionSymbol(fromWeathercode: ((entry["weather"] as! NSArray)[0] as! [String: AnyObject])["id"]! as! Int)
                let cityName = entry["name"]! as! String
                let rawTemperature = entry["main"]!["temp"]!! as! Double
                let cloudCoverage = entry["clouds"]!["all"]!! as! Double
                let humidity = entry["main"]!["humidity"]!! as! Double
                let windspeed = entry["wind"]!["speed"]!! as! Double
                
                let weatherDTO = WeatherData(condition: condition, cityName: cityName, rawTemperature: rawTemperature, cloudCoverage: cloudCoverage, humidity: humidity, windspeed: windspeed)
                multiLocationData.append(weatherDTO)
            }
            return multiLocationData
        }
        catch let jsonError as NSError {
            print("JSON error description: \(jsonError.description)")
            return [WeatherData]()
        }
    }
    
   //Function to process the weather codes and display the images accoridngly
    
    private func determineWeatherConditionSymbol(fromWeathercode: Int) -> String {
        switch fromWeathercode {
        case let x where (x >= 200 && x <= 202) || (x >= 230 && x <= 232):
            return "⛈"
        case let x where x >= 210 && x <= 211:
            return "🌩"
        case let x where x >= 212 && x <= 221:
            return "⚡️"
        case let x where x >= 300 && x <= 321:
            return "🌦"
        case let x where x >= 500 && x <= 531:
            return "🌧"
        case let x where x >= 600 && x <= 622:
            return "🌨"
        case let x where x >= 701 && x <= 771:
            return "🌫"
        case let x where x == 781 || x >= 958:
            return "🌪"
        case let x where x == 800:
            //Simulate the time of the day  sunset is considered from @ 18:00 and sunrise @ 07:00
            let currentDateFormatter: DateFormatter = DateFormatter()
            currentDateFormatter.dateFormat = "ddMMyyyy"
            let currentDateString: String = currentDateFormatter.string(from: Date())
            
            let zeroHourDateFormatter: DateFormatter = DateFormatter()
            zeroHourDateFormatter.dateFormat = "ddMMyyyyHHmmss"
            let zeroHourDate = zeroHourDateFormatter.date(from: (currentDateString + "000000"))!
            
            if Date().timeIntervalSince(zeroHourDate) > 64800 || Date().timeIntervalSince(zeroHourDate) < 25200 {
                return "✨"
            }
            else {
                return "☀️"
            }
        case let x where x == 801:
            return "🌤"
        case let x where x == 802:
            return "⛅️"
        case let x where x == 803:
            return "🌥"
        case let x where x == 804:
            return "☁️"
        case let x where x >= 952 && x <= 958:
            return "💨"
        default:
            return "☀️"
        }
    }

    
    //NSCoding Function
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(temperatureUnit.value.rawValue, forKey: PropertyKey.temperatureUnitKey)
        aCoder.encode(myCityLocation, forKey: PropertyKey.myCityLocationKey)
        aCoder.encode(numberResults, forKey: PropertyKey.numberResultsKey)
        aCoder.encode(singleLocWeatherData, forKey: PropertyKey.singleLocWeatherKey)
        aCoder.encode(multiLocWeatherData, forKey: PropertyKey.multiLocWeatherKey)
    }
    
    //Store the properties required
    struct PropertyKey {
        static let temperatureUnitKey = "temperatureUnit"
        static let myCityLocationKey = "myCityLocation"
        static let numberResultsKey = "chosennumberResults"
        static let singleLocWeatherKey = "singleLocWeatherData"
        static let multiLocWeatherKey = "multiLocWeatherData"
    }
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("mycity_weather.weather_service")
}

import UIKit

class Utils {
    func latLongToXY(_ lat:Double,_ long:Double) -> [String: Double] {
        let RE = 6371.00877; // 지구 반경(km)
        let GRID = 5.0; // 격자 간격(km)
        let SLAT1 = 30.0; // 투영 위도1(degree)
        let SLAT2 = 60.0; // 투영 위도2(degree)
        let OLON = 126.0; // 기준점 경도(degree)
        let OLAT = 38.0; // 기준점 위도(degree)
        let XO = 43.0; // 기준점 X좌표(GRID)
        let YO = 136.0; // 기1준점 Y좌표(GRID)
        
        let DEGRAD = Double.pi / 180.0
        
        let re = RE / GRID
        let slat1 = SLAT1 * DEGRAD
        let slat2 = SLAT2 * DEGRAD
        let olon = OLON * DEGRAD
        let olat = OLAT * DEGRAD
        
        var sn = tan(Double.pi * 0.25 + slat2 * 0.5) / tan(Double.pi * 0.25 + slat1 * 0.5)
        sn = log(cos(slat1) / cos(slat2)) / log(sn);
        var sf = tan(Double.pi * 0.25 + slat1 * 0.5);
        sf = pow(sf, sn) * cos(slat1) / sn;
        var ro = tan(Double.pi * 0.25 + olat * 0.5);
        ro = re * sf / pow(ro, sn);
        var ra = tan(Double.pi * 0.25 + (lat) * DEGRAD * 0.5);
        ra = re * sf / pow(ra, sn);
        var theta = long * DEGRAD - olon;
        if (theta > Double.pi) {
            theta -= 2.0 * Double.pi
        }
        if (theta < -Double.pi){
            theta += 2.0 * Double.pi;
        }
        theta *= sn;
        let x = floor(ra * sin(theta) + XO + 0.5)
        let y = floor(ro - ra * cos(theta) + YO + 0.5)
        return ["x": x, "y": y]
    }
    
    func getYesterday(dateFormat: String = "yyyyMMdd") -> String {
        let df = DateFormatter()
        df.dateFormat = dateFormat
        return df.string(from: Date(timeIntervalSinceNow: -86400))
    }
    
    func getToday(dateFormat: String = "yyyyMMdd") -> String {
        let df = DateFormatter()
        df.dateFormat = dateFormat
        return df.string(from: Date())
    }
  
    func getTime(dateFormat: String = "HHmm") -> String {
        return getToday(dateFormat: dateFormat)
    }
    
    func getKMAWeatherTime(_ standardMinute: Int) -> String {
        let currMinute:Int! = Int(getTime(dateFormat: "mm"));
        var hour:String!
        if currMinute > standardMinute {
            hour = getTime(dateFormat: "HH")
        } else {
            let intHour = Int(getTime(dateFormat: "HH"))! - 1
            if intHour < 0 {
               hour = "23"
            } else if intHour < 10 {
                hour = "0\(intHour)"
            } else {
                hour = "\(intHour)"
            }
        }
        
        return "\(hour ?? "00")\(String(currMinute))"
    }
    
    func checkLeap(year: Int) -> Bool {
        var checkValue: Bool = false
        if year % 4 == 0 && (year % 100 != 0 || year % 400 == 0){
            checkValue = true
        }else {
            checkValue = false
        }
        return checkValue
    }
    
    func endDayOfMonth(year: Int, month: Int) -> Int {
        var endDay: Int = 0
        let inputMonth: Int = month
        
        let monA: Set = [1,3,5,7,8,10,12]
        let monB: Set = [4,6,9,11]
        
        if monA.contains(inputMonth)  {
            endDay = 31
        }else if monB.contains(inputMonth) {
            endDay = 30
        }
        
        if inputMonth == 2 {
            if checkLeap(year: year) {
                endDay = 29
            }else {
                endDay = 28
            }
        }
        return endDay
    }
    func endOfMonth(atMonth: Int) -> Int {
        let set30: [Int] = [1,3,5,7,8,10,12]
        var endDay: Int = 0
        if atMonth == 2 {
            endDay = 28
        }else if set30.contains(atMonth) {
            endDay = 31
        }else {
            endDay = 30
        }
        
        return endDay
    }
    
    func getWeekDay(dateStr:String) -> String {
        let weekdays = [
            "일",
            "월",
            "화",
            "수",
            "목",
            "금",
            "토"
        ]
        let format = DateFormatter()
        format.locale = Locale(identifier: "ko_kr")
        format.timeZone = TimeZone(identifier: "KST")
        format.dateFormat = "yyyyMMdd"
        
        let date = format.date(from: dateStr)
        format.dateFormat = "MM/dd"
        
        let result:String = weekdays[Calendar.current.component(.weekday, from: date!) - 1]
        
        return "\(format.string(from: date!))(\(result))"
    }
    
    func getWindWay(_ windWay:Double) -> String {
        let windWayInt = Int((windWay + 22.5 * 0.5) / 22.5)
//        print("windWay=\(windWay) ==> windWayInt = \(windWayInt)")
        switch windWayInt {
        case 1:
            return "북북동"
        case 2:
            return "북동"
        case 3:
            return "동북동"
        case 4:
            return "동"
        case 5:
            return "동남동"
        case 6:
            return "남동"
        case 7:
            return "남남동"
        case 8:
            return "남"
        case 9:
            return "남남서"
        case 10:
            return "남서"
        case 11:
            return "서남서"
        case 12:
            return "서"
        case 13:
            return "서북서"
        case 14:
            return "북서"
        case 15:
            return "북북서"
        default :
            return "북"
        }
        
    }
    
    
    func getSkyImageName(RN1:Double, PTY:Int, SKY:Int, TIME:Int) -> String {
        print("RN1=\(RN1), PTY=\(PTY), SKY=\(SKY)")
        
        let isNight = TIME > 0600 && TIME < 2000 ? false : true
        print("TIME=\(TIME), isNight=\(isNight)")
        
        
        if RN1 > 0.0 || PTY != 0 { // 현재 강수량이 있으면..
            
            switch PTY {
            case 1: // 비
                return isNight ? "011-night-rain.png" : "038-sun-rain.png"
            case 2: // 비/눈
                return isNight ? "011-night-rain.png" : "038-sun-rain.png"
            case 3: // 눈
                return "042-snow.png" // 042
            case 4: // 소나기
                return "010-rain.png" // 010
            default: // 맑음
                return isNight ? "028-moon.png" : "050-sun.png" // 028 or 050
            }
            
        } else {
            
            switch SKY {
            case 2: // 구름조금
                return isNight ? "009-cloud.png" : "005-cloudy.png" //  009 or 005
            case 3: // 구름많음
//                return isNight ? "043-cloudy.png" : "003-cloudy.png" //  043 or 003
                return isNight ? "009-cloud.png" : "005-cloudy.png" //  009 or 005
            case 4: // 흐림
                return "049-clouds.png" // 049
            default: // 맑음
                return isNight ? "028-moon.png" : "050-sun.png" //  028 or 050
            }
            
        }
    }
    
    func getWeekSkyImageName(sky:String) -> String {
        if sky == "구름많음" || sky == "흐림" {
//            return "003-cloudy.png" //  043 or 003
            return "005-cloudy.png" //  009 or 005
            
        } else if sky == "구름많고 비" || sky == "구름많고 비/눈" || sky == "구름많고 눈/비" || sky == "흐리고 비" || sky == "흐리고 비/눈" || sky == "흐리고 눈/비" {
            return "038-sun-rain.png"
            
        } else if sky == "비" || sky == "비/눈" || sky == "눈/비" {
            return "038-sun-rain.png"
            
        } else if sky == "눈" || sky == "구름많고 눈" || sky == "흐리고 눈" {
            return "042-snow.png" // 042
            
        } else { // 맑음
            return "050-sun.png" //  028 or 050
        }
            
    }
    
    
}




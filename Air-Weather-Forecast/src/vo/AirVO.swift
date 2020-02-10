// 공기정보 VO
class AirVO {
    var pm10Value: String! // 미세먼지 수치
    var pm10Grade1h: String! // 미세먼지 등급
    var pm25Value: String! // 초미세먼지 수치
    var pm25Grade1h: String! // 초미세먼지 등급
    var o3Value: String! // 오존 수치
    var o3Grade: String! // 오존 등급
    
    var isComplete = false
}

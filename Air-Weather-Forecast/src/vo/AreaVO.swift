// 지역정보 VO
class AreaVO {
    var sido: String! = "" // 시도
    var gu: String! = "" // 군구
    var dong: String! = "" // 동
    var gionCode: String! = "" // 동
    var yeboCode: String! = "" // 동
    
    var stationName: String! = "" // 측정소명
    
    var latitude: Double = 0 // 위도
    var longtitude: Double = 0 // 경도
    var areaX: Int! = 0 // 기상청 x좌표
    var areaY: Int! = 0 // 기상청 y좌표
    var tmX: Double = 0 // 미세먼지 측정소 tm x좌표
    var tmY: Double = 0 // 미세먼지 측정소 tm y좌표
}

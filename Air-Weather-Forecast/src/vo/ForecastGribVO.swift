// 초단기실황 VO
class ForecastGribVO {
    var T1H: Double! // 기온     ℃
    var RN1: Double! // 1시간 강수량    mm
    var UUU: Double! // 동서바람성분    m/s
    var VVV: Double! // 남북바람성분    m/s
    var REH: Double! // 습도    %
    var PTY: Double! // 강수형태    코드값
    var VEC: Double! // 풍향    0
    var WSD: Double! // 풍속    1
    
    var isComplete = false
}

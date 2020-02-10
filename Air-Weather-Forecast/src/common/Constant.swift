import UIKit

struct Constant {
    // 테스트 관련 상수.
    static let IS_TEST = false // 테스트여부
    static let IS_LOCAL = false // 로컬 여부
    
    // KAKAO_API
    static let KAKAO_API_KEY = "KakaoAK KEY~~~~~~~~~~~"
    static let KAKAO_API_URL = "https://dapi.kakao.com/v2/local/geo/coord2regioncode.json" // 지역정보
    
    // 공공API_KEY
    static let GO_KEY = "KEY~~~~~~~~~~~"
    
    // 기상청 API 주소
    static let KMA_URL = "http://newsky2.kma.go.kr/service/SecndSrtpdFrcstInfoService2"
    static let KMA_SPACE_URL = "\(KMA_URL)/ForecastSpaceData?serviceKey=\(GO_KEY)&numOfRows=500&pageNo=1&_type=json" // 동네예보(시간별 기온, 강수확률 강수형태 등...)
    static let KMA_TIME_URL = "\(KMA_URL)/ForecastTimeData?serviceKey=\(GO_KEY)&numOfRows=500&pageNo=1&_type=json" // 초단기예보(현재시간 하늘예보)
    static let KMA_GRIB_URL = "\(KMA_URL)/ForecastGrib?serviceKey=\(GO_KEY)&numOfRows=500&pageNo=1&_type=json" // 초단기실황(현재 기상상황)
    static let KMA_SUCCESS_CODE = "0000"
    
    // 공기측정소 API
    static let AIR_URL = "http://openapi.airkorea.or.kr/openapi/services/rest"
    static let TM_XY_URL = "\(AIR_URL)/MsrstnInfoInqireSvc/getTMStdrCrdnt?serviceKey=\(GO_KEY)&numOfRows=1&pageNo=1" // tm X/Y좌표
    static let STATION_NM_URL = "\(AIR_URL)/MsrstnInfoInqireSvc/getNearbyMsrstnList?serviceKey=\(GO_KEY)" // 측정소 정보
    static let AIR_INFO_URL = "\(AIR_URL)/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty?serviceKey=\(GO_KEY)" // 공기정보
    
    static let WEEK_URL = "http://newsky2.kma.go.kr/service/MiddleFrcstInfoService"
    static let WEEK_GION_URL = "\(WEEK_URL)/getMiddleTemperature?serviceKey=\(GO_KEY)&pageNo=1&numOfRows=100"
    static let WEEK_YEBO_URL = "\(WEEK_URL)/getMiddleLandWeather?serviceKey=\(GO_KEY)&pageNo=1&numOfRows=100"

    
    // 앱 최초실행 상수.
    static let IS_AREA_SELECT = "IS_AREA_SELECT" // 지역 선택여부
    
    // 지역설정 관련 상수
    static let AREA_NAME = "AREA_NAME" // 지역명
    static let AREA_X = "AREA_X" // 지역 x좌표
    static let AREA_Y = "AREA_Y" // 지역 Y좌표

}


import UIKit
import Alamofire
import CoreLocation
import SystemConfiguration

class ForecastMainVC: UIViewController, CLLocationManagerDelegate {
    // 유틸
    let forecastDAO = ForecastDAO()
    let utils = Utils()
    
    @IBOutlet var splashLabel: UILabel!
    
    // VO
    let spaceVO = ForecastSpaceVO() // 동네예보정보 VO(시간별 일기예보정보가 들어있다.)
    let timeVO = ForecastTimeVO() // 초단기예보 VO(현재시간 기상예보)
    let gribVO = ForecastGribVO() // 초단기실황 VO(현재시간 기상실황)
    let areaVO = AreaVO() // 현재위치 VO
    let airVO = AirVO() // 미세먼지 VO
    let weekVO = WeekVO() // 주간예보 VO
    
    var locationManager:CLLocationManager! = CLLocationManager()
    
    var isSplashShow = false // splash화면 떠있는지 여부.
    var isCoordinateInit = false // 좌표정보 가져왔는지 여부.
    var isLoading = false // 기상정보 로딩중인지 여부.

    let splashGradientLayer = CAGradientLayer() // 그라데이션 배경처리위한 Layer
    var splashView: UIImageView! // splash담당 View
    
    // 메인 스크롤뷰
    var weatherScrollview = UIScrollView() // 메인스크롤뷰 - 오늘날씨, 주간날씨를 전부 포함한다.
    var todayScrollView = UIScrollView() // 오늘날씨 스크롤뷰
    var weekScrollView = UIScrollView() // 주간날씨 스크롤뷰
    
    // 오늘날씨 레이아웃 뷰
    var weatherIconAreaView = UIView() // 지역, 현재기온, 하늘상태이미지
    var airAreaView = UIView() // 공기정보
    var dummy1View = UIView() // DUMMY View(레이아웃용)
    var todayWeatherTimeScrollAreaView = UIScrollView() // 시간별 기상정보
    var dummy2View = UIView() // DUMMY View(레이아웃용)
    var weekWeatherScrollAreaView = UIScrollView() // 시간별 기상정보
    var dummy3View = UIView() // DUMMY View(레이아웃용)
    var appInfoAreaView = UIView() // App 소개정보
    var dummy4View = UIView() // DUMMY View(레이아웃용)

    
    // weatherIconAreaView에 들어가는 UI
    var locationInfo = UILabel() // 지역, 현재기온
    var skyImage = UIImageView() // 하늘상태이미지
    
    
    // airAreaView에 들어가는 UI
    let fineDustTitle = UILabel() // 미세먼지 타이틀
    let fineDustValue = UILabel() // 미세먼지 수치
    let fineDustGrade = UILabel() // 미세먼지 등급
    let ultrafineDustTitle = UILabel() // 초미세먼지 타이틀
    let ultrafineDustValue = UILabel() // 초미세먼지 수치
    let ultrafineDustGrade = UILabel() // 초미세먼지 등급
    let ozoneTitle = UILabel() // 오존 타이틀
    let ozoneValue = UILabel() // 오존 수치
    let ozoneGrade = UILabel() // 오존 등급
    let airCommentLabel = UILabel() // 공기정보 코멘트
    
    // appInfoAreaView에 들어가는 UI
    let appWeatherInfoLabel = UITextView() // API정보 안내 TextView
    let licenceLabel1 = UILabel() // API정보 안내 TextView
    let licenceLabel2 = UILabel() // API정보 안내 TextView
    let licenceLabel3 = UILabel() // API정보 안내 TextView

    
    // 디자인관련 변수
    let mainGradientLayer = CAGradientLayer() // 그라데이션 배경처리위한 Layer
    let screenWidth = UIScreen.main.bounds.size.width // 뷰 전체 폭 길이
    let screenHeight = UIScreen.main.bounds.size.height // 뷰 전체 높이 길이
    let fontColor = UIColor.white // 공통 폰트컬러
    
    var currentElement = "" // XML파싱용.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("viewDidLoad")
        
        let isConnected = self.connectedToNetwork();
        NSLog("isConnected : \(isConnected)")
        
        if isConnected {
            self.isLoading = true
            self.showSplash()
            self.drawLayout();
            self.loadAreaInfo();
        } else {
            alert("네트워크 상태를 확인해주세요.") {
                exit(0);
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NSLog("viewDidAppear")
        if self.isLoading == false {
            self.getWeatherInfo()
        }
    }
    
    
    func drawLayout(){
        NSLog("drawLayout start")
        self.view.layer.addSublayer(mainGradientLayer)
        
        // 메인 스크롤뷰 그리기
        // 디바이스 메인 기준으로 포인트를 잡아줘야 한다.
        todayScrollView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        weekScrollView.frame = CGRect(x: screenWidth, y: 0, width: screenWidth, height: screenHeight)
        weekScrollView.backgroundColor = .brown
        
        
        // 1. 위치/기온/하늘정보
        weatherIconAreaView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 220)
        
        // 2. 공기정보
        let airAreaViewY:CGFloat = weatherIconAreaView.frame.origin.y + weatherIconAreaView.frame.height
        airAreaView.frame = CGRect(x: 0, y: airAreaViewY, width: screenWidth - screenWidth/30, height: 180 )
        airAreaView.layer.cornerRadius = 15;
        airAreaView.layer.masksToBounds = true;
        airAreaView.layer.borderColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0).cgColor
        airAreaView.layer.borderWidth = 5;
        airAreaView.center = CGPoint(x: screenWidth/2, y: airAreaView.frame.origin.y + airAreaView.frame.height/2)
        
        // 3. DUMMY
        let dummy1ViewY:CGFloat = airAreaView.frame.origin.y + airAreaView.frame.height
        dummy1View.frame = CGRect(x: 0, y: dummy1ViewY, width: screenWidth, height: 8 )
        
        // 4. 시간별 기상정보
        let todayWeatherTimeScrollAreaViewY:CGFloat = dummy1View.frame.origin.y + dummy1View.frame.height
        todayWeatherTimeScrollAreaView.frame = CGRect(x: 0, y: todayWeatherTimeScrollAreaViewY, width: screenWidth, height: 305 )
        todayWeatherTimeScrollAreaView.center = CGPoint(x: screenWidth/2, y: todayWeatherTimeScrollAreaView.frame.origin.y + todayWeatherTimeScrollAreaView.frame.height/2)
        todayWeatherTimeScrollAreaView.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:0.10)
        
        // 5. DUMMY
        let dummy2ViewY:CGFloat = todayWeatherTimeScrollAreaView.frame.origin.y + todayWeatherTimeScrollAreaView.frame.height
        dummy2View.frame = CGRect(x: 0, y: dummy2ViewY, width: screenWidth, height: 20 )
        
        // 6. 주간예보
        let weekWeatherScrollAreaViewY:CGFloat = dummy2View.frame.origin.y + dummy2View.frame.height
        weekWeatherScrollAreaView.frame = CGRect(x: 0, y: weekWeatherScrollAreaViewY, width: screenWidth, height: 140 )
        weekWeatherScrollAreaView.center = CGPoint(x: screenWidth/2, y: weekWeatherScrollAreaView.frame.origin.y + weekWeatherScrollAreaView.frame.height/2)
        weekWeatherScrollAreaView.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:0.10)
        
        // 7. DUMMY
        let dummy3ViewY:CGFloat = weekWeatherScrollAreaView.frame.origin.y + weekWeatherScrollAreaView.frame.height
        dummy3View.frame = CGRect(x: 0, y: dummy3ViewY, width: screenWidth, height: 5 )
        
        // 8. API정보
        let appInfoAreaViewY:CGFloat = dummy3View.frame.origin.y + dummy3View.frame.height
        appInfoAreaView.frame = CGRect(x: 0, y: appInfoAreaViewY, width: screenWidth - screenWidth/30, height: 170 )
        appInfoAreaView.layer.cornerRadius = 15;
        appInfoAreaView.layer.masksToBounds = true;
        appInfoAreaView.layer.borderColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0).cgColor;
        appInfoAreaView.layer.borderWidth = 5;
        appInfoAreaView.center = CGPoint(x: screenWidth/2, y: appInfoAreaView.frame.origin.y + appInfoAreaView.frame.height/2)
        
        // 7. DUMMY
        let dummy4ViewY:CGFloat = appInfoAreaView.frame.origin.y + appInfoAreaView.frame.height
        dummy4View.frame = CGRect(x: 0, y: dummy4ViewY, width: screenWidth, height: 10 )

        
        
        
        
        
        // 1-1. 최상단 지역정보, 온도, 하늘이미지
        locationInfo.frame = CGRect(x: 0, y: 25, width: 200, height: 30)
        
        // 1-2 하늘상태 아이콘 이미지
        let skyImageY:CGFloat = locationInfo.frame.origin.y + locationInfo.frame.height + 23
        skyImage.frame = CGRect(x: 0, y: skyImageY, width: 130, height: 130)
        skyImage.center = CGPoint(x: weatherIconAreaView.frame.size.width/2, y: skyImage.frame.origin.y + skyImage.frame.height/2)
        
        weatherIconAreaView.addSubview(locationInfo)
        weatherIconAreaView.addSubview(skyImage)
        
        
        
        // 페이징 설정
        // 디폴트는 false이며 뷰 단위로 스크롤한다.
        todayScrollView.isPagingEnabled = false
        todayScrollView.decelerationRate = UIScrollView.DecelerationRate.normal; // 스크롤속도
        
        
        
        // API정보
        appWeatherInfoLabel.frame = CGRect(x: 0, y: 0, width: screenWidth - screenWidth/30, height: 65)
        appWeatherInfoLabel.text = "날씨정보 : 기상청 공공데이터포털 API\n미세먼지 : 환경부/한국환경공단 API\n지역정보 : KAKAO 주소 API\n\n데이터는 실시간 관측된 자료이며\n측정소 현지 사정이나 데이터의 수신상태에 따라\n미수신될 수 있습니다."
        appWeatherInfoLabel.font = UIFont.systemFont(ofSize: 13)
        appWeatherInfoLabel.textAlignment = .center
        appWeatherInfoLabel.textColor = fontColor
        appWeatherInfoLabel.sizeToFit()
        appWeatherInfoLabel.center = CGPoint(x: screenWidth/2, y: appWeatherInfoLabel.frame.origin.y + appWeatherInfoLabel.frame.height/2)
        appWeatherInfoLabel.backgroundColor = .none
        appWeatherInfoLabel.isEditable = false
//        appWeatherInfoLabel.backgroundColor = .yellow
        
        
        licenceLabel1.frame = CGRect(x: 0, y: 0, width: screenWidth - screenWidth/30, height: 15)
        licenceLabel1.text = "Icons made by iconixar"
        licenceLabel1.font = UIFont.systemFont(ofSize: 13)
        licenceLabel1.textAlignment = .center
        licenceLabel1.textColor = fontColor
        licenceLabel1.sizeToFit()
        licenceLabel1.center = CGPoint(x: screenWidth/2, y: appWeatherInfoLabel.frame.height+10)
        licenceLabel1.isUserInteractionEnabled = true
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.moveLicencePage1(sender:)))
        licenceLabel1.addGestureRecognizer(tap1)

        
        licenceLabel2.frame = CGRect(x: 0, y: 80, width: screenWidth - screenWidth/30, height: 15)
        licenceLabel2.text = "from www.flaticon.com"
        licenceLabel2.font = UIFont.systemFont(ofSize: 13)
        licenceLabel2.textAlignment = .center
        licenceLabel2.textColor = fontColor
        licenceLabel2.sizeToFit()
        licenceLabel2.center = CGPoint(x: screenWidth/2, y: appWeatherInfoLabel.frame.height+25)
        licenceLabel2.isUserInteractionEnabled = true
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.moveLicencePage2(sender:)))
        licenceLabel2.addGestureRecognizer(tap2)
        
        licenceLabel3.frame = CGRect(x: 0, y: 95, width: screenWidth - screenWidth/30, height: 15)
        licenceLabel3.text = "is licensed by CC 3.0 BY"
        licenceLabel3.font = UIFont.systemFont(ofSize: 13)
        licenceLabel3.textAlignment = .center
        licenceLabel3.textColor = fontColor
        licenceLabel3.sizeToFit()
        licenceLabel3.center = CGPoint(x: screenWidth/2, y: appWeatherInfoLabel.frame.height+40)
        licenceLabel3.isUserInteractionEnabled = true
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(self.moveLicencePage3(sender:)))
        licenceLabel3.addGestureRecognizer(tap3)
        
        appInfoAreaView.addSubview(appWeatherInfoLabel)
        appInfoAreaView.addSubview(licenceLabel1)
        appInfoAreaView.addSubview(licenceLabel2)
        appInfoAreaView.addSubview(licenceLabel3)

        
        
        // 오늘날씨에 레이아웃UI들 추가.
        todayScrollView.addSubview(weatherIconAreaView)
        todayScrollView.addSubview(airAreaView)
        todayScrollView.addSubview(dummy1View)
        todayScrollView.addSubview(todayWeatherTimeScrollAreaView)
        todayScrollView.addSubview(dummy2View)
        todayScrollView.addSubview(appInfoAreaView)
        todayScrollView.addSubview(dummy3View)
        todayScrollView.addSubview(weekWeatherScrollAreaView)
        todayScrollView.addSubview(dummy4View)
        
        // 오늘날씨 컨텐츠사이즈 지정.
        todayScrollView.contentSize = CGSize(width: screenWidth, height: dummy4ViewY+dummy4View.frame.height)

        
        // 날씨뷰에 오늘날씨 추가(첫페이지 오늘날씨)
        weatherScrollview.frame = CGRect(x: 0, y: 0, width: screenWidth, height: todayScrollView.frame.height)
        weatherScrollview.addSubview(todayScrollView)
        weatherScrollview.contentSize = CGSize(width: screenWidth, height: todayScrollView.frame.height)

        // 주간날씨 추가할경우, 아래주석 해제
//        weatherScrollview.addSubview(weekScrollView)
//        weatherScrollview.contentSize = CGSize(width: screenWidth, height: todayScrollView.frame.height)

        
        weatherScrollview.isPagingEnabled = true
        
        
        
        
    } // func drawLayout()
    
    
    func showSplash(){
        splashView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        splashView.image = UIImage(named: "splash_grad.png")
        splashView.contentMode = .scaleToFill
        view.addSubview(splashView)
        view.bringSubviewToFront(splashView)
    }
    
    
    func changeView() {
//        splashView.removeFromSuperview()
        mainGradientLayer.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.view.addSubview(weatherScrollview)
    }
    
    
    
    // 위도, 경도정보 취득
    func loadAreaInfo() {
        NSLog("loadAreaInfo start")
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        NSLog("requestWhenInUseAuthorization")
        
        // 사전동의가 되어있을때.
        if let coor = locationManager.location?.coordinate {
            NSLog("latitude=\(coor.latitude), longtitude=\(coor.longitude)")
            
            if Constant.IS_TEST {
                self.areaVO.latitude = 37.49162880006584
                self.areaVO.longtitude = 126.88916194362048
            } else {
                self.areaVO.latitude = Double(coor.latitude)
                self.areaVO.longtitude = Double(coor.longitude)
            }
            
            self.latLongToXY(self.areaVO.latitude, self.areaVO.longtitude)
            self.isCoordinateInit = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.notDetermined { // 동의\거절 팝업 노출전
            NSLog("CLAuthorizationStatus = notDetermined")
        } else if status == CLAuthorizationStatus.authorizedWhenInUse || status == CLAuthorizationStatus.authorizedAlways { // 승인
            NSLog("CLAuthorizationStatus = authorizedAlways || authorizedWhenInUse")
            
        } else if status == CLAuthorizationStatus.denied { // 거절
            NSLog("CLAuthorizationStatus = denied")
            alert("설정에서 위치정보 동의 후 다시 실행해주세요.") {
                exit(0);
            }
        }
    }
    
    // (사전동의가 뒤늦게 되었을때) 위도, 경도 취득.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard self.isCoordinateInit == false else {
            return
        }
        NSLog("AreaSelectVC - didUpdateLocations")
        
        if Constant.IS_TEST {
            self.areaVO.latitude = 37.49162880006584
            self.areaVO.longtitude = 126.88916194362048
        } else {
            let latestLocation: AnyObject = locations[locations.count - 1]
            self.areaVO.latitude = Double(latestLocation.coordinate.latitude)
            self.areaVO.longtitude = Double(latestLocation.coordinate.longitude)
        }
        
        self.latLongToXY(self.areaVO.latitude, self.areaVO.longtitude)
        self.isCoordinateInit = true
    }
    
    // 위도, 경도를 기상청 좌표로 변환한다.
    func latLongToXY(_ lat:Double, _ long:Double){
        let mapInfo = utils.latLongToXY(lat, long)
        self.areaVO.areaX = Int(mapInfo["x"]!)
        self.areaVO.areaY = Int(mapInfo["y"]!)
        NSLog("x=\(String(self.areaVO.areaX)), y=\(String(self.areaVO.areaY))")
        
        // 기상청좌표로 지역명을 조회한다.
        self.getWeatherInfo()
    }
    
    
    func getWeatherInfo(){
        self.getWeatherSpaceInfo() // 동네예보
        self.getWeatherGribInfo() // 초단기실황
        self.getWeatherTimeInfo() // 초단기예보
        self.getAreaInfo() // 지역정보(카카오API coord2regioncode)
        self.getWeekCode() // 주간예보
    }
    
    // 주간예보 조회용 코드 취득.
    func getWeekCode() {
        let weekCodeVO = forecastDAO.selectTodayArea(X: self.areaVO.areaX!, Y: self.areaVO.areaY!)
        NSLog("기온코드=\(weekCodeVO.gionCode!), 예보코드=\(weekCodeVO.yeboCode!)")
        
        self.getWeekGIONInfo(weekCodeVO.gionCode!)
        self.getWeekYEBOInfo(weekCodeVO.yeboCode!)
    }
    
    // 주간기온 데이터 취득.(AJAX)
    func getWeekGIONInfo(_ gionCode: String) {
        let time = Int(utils.getTime())
        var date:String? = nil;
        if time! < 0600 {
            date = utils.getYesterday()
        } else {
            date = utils.getToday()
        }
        let WEEK_GION_URL = "\(Constant.WEEK_GION_URL)&regId=\(gionCode)&tmFc=\(date!)0600"
        NSLog("getWeekGIONInfo call - \(WEEK_GION_URL)")
        let parser = XMLParser(contentsOf: URL(string: WEEK_GION_URL)!)
        parser?.delegate = self
        parser?.parse()
        
        
        weekVO.isWeekGIONComplete = true;
        self.getWeekWeatherComplete();
    }
    
    // 주간예보 데이터 취득.(AJAX)
    func getWeekYEBOInfo(_ yeboCode: String) {
        let time = Int(utils.getTime())
        var date:String? = nil;
        if time! < 0600 {
            date = utils.getYesterday()
        } else {
            date = utils.getToday()
        }
        let WEEK_YEBO_URL = "\(Constant.WEEK_YEBO_URL)&regId=\(yeboCode)&tmFc=\(date!)0600"
        NSLog("getWeekYEBOInfo call - \(WEEK_YEBO_URL)")
        let parser = XMLParser(contentsOf: URL(string: WEEK_YEBO_URL)!)
        parser?.delegate = self
        parser?.parse()
        
        weekVO.isWeekYEBOComplete = true;
        self.getWeekWeatherComplete();
    }
    
    func getWeekWeatherComplete(){
        guard weekVO.isWeekGIONComplete && weekVO.isWeekYEBOComplete else {
            return;
        }
        weekVO.isWeekComplete = true;
        self.viewWeatherInfo()
    }
    
    // 주간예보 화면 출력
    func showWeekWeatherInfo(){
        let today = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        
        var weekKeyArray = [String]()
        var weekDictionary = [String: Dictionary<String, Any>]()
        
        for i in 3...10 {
//        for i in 3...7 {

            let date = Calendar.current.date(byAdding: .day, value: i, to: today)
            let dateStr = df.string(from: date!)
            let weekDay = utils.getWeekDay(dateStr: dateStr)
            
            weekKeyArray.append(dateStr)
            weekDictionary[dateStr] = [String: String]()
            (weekDictionary[dateStr])?["weekDay"] = weekDay
            
            if i == 3 {
                (weekDictionary[dateStr])?["taMin"] = weekVO.taMin3
                (weekDictionary[dateStr])?["taMax"] = weekVO.taMax3
                (weekDictionary[dateStr])?["wfAm"] = weekVO.wf3Am
                (weekDictionary[dateStr])?["wfPm"] = weekVO.wf3Pm
            } else if i == 4 {
                (weekDictionary[dateStr])?["taMin"] = weekVO.taMin4
                (weekDictionary[dateStr])?["taMax"] = weekVO.taMax4
                (weekDictionary[dateStr])?["wfAm"] = weekVO.wf4Am
                (weekDictionary[dateStr])?["wfPm"] = weekVO.wf4Pm
            } else if i == 5 {
                (weekDictionary[dateStr])?["taMin"] = weekVO.taMin5
                (weekDictionary[dateStr])?["taMax"] = weekVO.taMax5
                (weekDictionary[dateStr])?["wfAm"] = weekVO.wf5Am
                (weekDictionary[dateStr])?["wfPm"] = weekVO.wf5Pm
            } else if i == 6 {
                (weekDictionary[dateStr])?["taMin"] = weekVO.taMin6
                (weekDictionary[dateStr])?["taMax"] = weekVO.taMax6
                (weekDictionary[dateStr])?["wfAm"] = weekVO.wf6Am
                (weekDictionary[dateStr])?["wfPm"] = weekVO.wf6Pm
            } else if i == 7 {
                (weekDictionary[dateStr])?["taMin"] = weekVO.taMin7
                (weekDictionary[dateStr])?["taMax"] = weekVO.taMax7
                (weekDictionary[dateStr])?["wfAm"] = weekVO.wf7Am
                (weekDictionary[dateStr])?["wfPm"] = weekVO.wf7Pm
            } else if i == 8 {
                (weekDictionary[dateStr])?["taMin"] = weekVO.taMin8
                (weekDictionary[dateStr])?["taMax"] = weekVO.taMax8
                (weekDictionary[dateStr])?["wf"] = weekVO.wf8
            } else if i == 9 {
                (weekDictionary[dateStr])?["taMin"] = weekVO.taMin9
                (weekDictionary[dateStr])?["taMax"] = weekVO.taMax9
                (weekDictionary[dateStr])?["wf"] = weekVO.wf9
            } else if i == 10 {
                (weekDictionary[dateStr])?["taMin"] = weekVO.taMin10
                (weekDictionary[dateStr])?["taMax"] = weekVO.taMax10
                (weekDictionary[dateStr])?["wf"] = weekVO.wf10
            }
        }
        
        
        let dateLabelY:CGFloat = 10 // 날짜
        let timeLabelY:CGFloat = 35 // 시간
        let skyImageY:CGFloat = 72 // 날씨
        let gionLabelY:CGFloat = 110 // 기온
        
        
        var cnt = 0;
        let weekInfoWidth:Int = 130
        let leftX:CGFloat = CGFloat(weekInfoWidth/3-7)
        let rightX:CGFloat = CGFloat(weekInfoWidth/3*2+7)
        for key in weekKeyArray {
            var info: Dictionary<String, Any> = weekDictionary[key]!
            
            
            let timeInfoView = UIView()
            timeInfoView.frame = CGRect(x: (weekInfoWidth * cnt)+5, y: 10, width: weekInfoWidth, height: Int(weekWeatherScrollAreaView.frame.height))
            
            
            let dateLabel = UILabel()
            dateLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
            dateLabel.text = info["weekDay"] as? String
            dateLabel.textColor = fontColor
            dateLabel.sizeToFit()
            dateLabel.center = CGPoint(x: timeInfoView.frame.width/2, y: dateLabelY)
            timeInfoView.addSubview(dateLabel)
            if(cnt<5){
                let timeLabel1 = UILabel()
                timeLabel1.frame = CGRect(x: 0, y: 15, width: 50, height: 20)
                timeLabel1.text = "오전"
                timeLabel1.textColor = fontColor
                timeLabel1.sizeToFit()
                timeLabel1.center = CGPoint(x: leftX, y: timeLabelY)
                
                let timeLabel2 = UILabel()
                timeLabel2.frame = CGRect(x: 60, y: 15, width: 50, height: 20)
                timeLabel2.text = "오후"
                timeLabel2.textColor = fontColor
                timeLabel2.sizeToFit()
                timeLabel2.center = CGPoint(x: rightX, y: timeLabelY)
                
                
                let skyImageName1 = utils.getWeekSkyImageName(sky: info["wfAm"] as! String)
                let skyImage1 = UIImageView()
                skyImage1.frame = CGRect(x: 0, y: 15, width: 35, height: 35)
                skyImage1.center = CGPoint(x: leftX, y: skyImageY)
                skyImage1.image = UIImage(named: skyImageName1)
                
                let skyImageName2 = utils.getWeekSkyImageName(sky: info["wfPm"] as! String)
                let skyImage2 = UIImageView()
                skyImage2.frame = CGRect(x: 60, y: 15, width: 35, height: 35)
                skyImage2.center = CGPoint(x: rightX+1, y: skyImageY)
                skyImage2.image = UIImage(named: skyImageName2)
                
                timeInfoView.addSubview(timeLabel1)
                timeInfoView.addSubview(timeLabel2)
                timeInfoView.addSubview(skyImage1)
                timeInfoView.addSubview(skyImage2)
                
            } else {
                let timeLabel = UILabel()
                timeLabel.frame = CGRect(x: 0, y: 15, width: 50, height: 20)
                timeLabel.text = "-"
                timeLabel.textColor = fontColor
                timeLabel.sizeToFit()
                timeLabel.center = CGPoint(x: CGFloat(weekInfoWidth/2), y: timeLabelY)
            
                let skyImageName = utils.getWeekSkyImageName(sky: info["wf"] as! String)
                let skyImage = UIImageView()
                skyImage.frame = CGRect(x: 0, y: 15, width: 40, height: 40)
                skyImage.center = CGPoint(x: CGFloat(weekInfoWidth/2), y: skyImageY)
                skyImage.image = UIImage(named: skyImageName)
                
                timeInfoView.addSubview(timeLabel)
                timeInfoView.addSubview(skyImage)
            }
            
            let gionMinLabel = UILabel()
            gionMinLabel.frame = CGRect(x: 0, y: 15, width: 50, height: 20)
            gionMinLabel.text = "\(info["taMin"] ?? "")℃" // 기온
            gionMinLabel.textColor = fontColor
            gionMinLabel.sizeToFit()
            gionMinLabel.center = CGPoint(x: leftX, y: gionLabelY)
            
            let gionMaxLabel = UILabel()
            gionMaxLabel.frame = CGRect(x: 0, y: 15, width: 50, height: 20)
            gionMaxLabel.text = "\(info["taMax"] ?? "")℃" // 기온
            gionMaxLabel.textColor = fontColor
            gionMaxLabel.sizeToFit()
            gionMaxLabel.center = CGPoint(x: rightX, y: gionLabelY)
            timeInfoView.addSubview(gionMinLabel)
            timeInfoView.addSubview(gionMaxLabel)
            
            weekWeatherScrollAreaView.addSubview(timeInfoView)
            cnt = cnt + 1
        }
        
        
        weekWeatherScrollAreaView.contentSize = CGSize(width: CGFloat(cnt * (weekInfoWidth+5) ), height: weekWeatherScrollAreaView.frame.height)
        weekWeatherScrollAreaView.decelerationRate = UIScrollView.DecelerationRate.normal; // 스크롤속도
        
    }
        
    
    // 지역정보 취득
    func getAreaInfo(){
        let URL = "\(Constant.KAKAO_API_URL)?x=\(self.areaVO.longtitude)&y=\(self.areaVO.latitude)"

        Alamofire.request("\(URL)", method: .get, encoding: JSONEncoding.prettyPrinted, headers: ["Authorization": Constant.KAKAO_API_KEY]).responseJSON { (res) in
            switch res.result {
            case .success(let json):
                // 검색에 성공을 하면 검색 결과가 json으로 넘어 옵니다. 이 값을 통해 원하는 화면을 표시 하면됩니다.
                
                let obj = json as! [String: Any]
                if let documents = obj["documents"] as? [Any] {
                    for i in documents {
                        let areaObj = i as! [String: Any]
                        self.areaVO.sido = (areaObj["region_1depth_name"] as! String)
                        self.areaVO.gu = (areaObj["region_2depth_name"] as! String)
                        self.areaVO.dong = (areaObj["region_3depth_name"] as! String)
                        
                        self.getStationTMXYInfo()
                        break;
                    }
                }
                
            case .failure(let error):
                // 검색에 실패할 경우 error 메세지와 함께 넘어옵니다.
                NSLog("Request failed with error: \(error)")
            }
            
        }
    }
    
    
    // 동네예보 AJAX호출
    func getWeatherSpaceInfo(){
        let time = Int(utils.getTime())
        var date:String? = nil;
        if time! < 0500 {
            date = utils.getYesterday()
        } else {
            date = utils.getToday()
        }
        
        let URL = "\(Constant.KMA_SPACE_URL)&base_date=\(date!)&base_time=0500&nx=\(String(self.areaVO.areaX))&ny=\(String(self.areaVO.areaY))"
        
        Alamofire.request("\(URL)").responseJSON { (res) in
            guard res.result.isSuccess else {
                self.alert("기상정보를 가져오는데 실패하였습니다.\n잠시 후 다시 시도해 주세요.") {
                    exit(0);
                }
                return
            }
            let spaceObj = res.result.value as? [String: Any]
            if spaceObj != nil  {
                NSLog("getWeatherSpaceInfo - 파싱성공!!!")
                self.printWeatherSpaceInfo(spaceObj!)
            } else {
                NSLog("getWeatherSpaceInfo - 파싱실패")
            }
        }
    }
    
    // 초단기예보 AJAX호출
    func getWeatherTimeInfo(){
        let URL = "\(Constant.KMA_TIME_URL)&base_date=\(utils.getToday())&base_time=\(utils.getKMAWeatherTime(45))&nx=\(String(self.areaVO.areaX))&ny=\(String(self.areaVO.areaY))"
        
        Alamofire.request("\(URL)").responseJSON { (res) in
            guard res.result.isSuccess else {
                self.alert("기상정보를 가져오는데 실패하였습니다.\n잠시 후 다시 시도해 주세요.") {
                    exit(0);
                }
                return
            }
            
            let timeObj = res.result.value as? [String: Any]
            if timeObj != nil  {
                NSLog("getWeatherTimeInfo - 파싱성공!!!")
                self.printWeatherTimeInfo(timeObj!)
            } else {
                NSLog("getWeatherTimeInfo - 파싱실패")
            }
        }
    }
    
    // 초단기실황 AJAX호출
    func getWeatherGribInfo(){
        let URL = "\(Constant.KMA_GRIB_URL)&base_date=\(utils.getToday())&base_time=\(utils.getKMAWeatherTime(40))&nx=\(String(self.areaVO.areaX))&ny=\(String(self.areaVO.areaY))"
        
        Alamofire.request(URL).responseJSON { (res) in
            guard res.result.isSuccess else {
                self.alert("기상정보를 가져오는데 실패하였습니다.\n잠시 후 다시 시도해 주세요.") {
                    exit(0);
                }
                return
            }
            
            let gribObj = res.result.value as? [String: Any]
            if gribObj != nil  {
                NSLog("getWeatherGribInfo - 파싱성공!!!")
                NSLog(URL)
                NSLog("\(gribObj!)")

                self.printWeatherGribInfo(gribObj!)
            } else {
                NSLog("getWeatherGribInfo - 파싱실패")
            }
        }
    }
    
    
    // 초단기실황 출력.
    func printWeatherGribInfo(_ gribObj:[String: Any]){
        let response = gribObj["response"] as! [String : Any]
        let header = response["header"] as! [String : Any]
        let body = response["body"] as! [String : Any]

        let resultCode = header["resultCode"] as! String
        let totalCount = body["totalCount"] as! Int
        NSLog("[grib] resultCode=\(resultCode)")
        NSLog("[grib] totalCount=\(totalCount)")
        
        guard resultCode == Constant.KMA_SUCCESS_CODE && totalCount > 0 else {
            NSLog("[grib] guard return : resultCode=\(resultCode), totalCount=\(totalCount)")
            return
        }
        
        let items = (body["items"] as! [String : Any])
        let item = items["item"] as! [Any]
        
        for i in item {
            let infoObj = i as! [String : Any]
            let category: String! = (infoObj["category"] as! String)
//            NSLog("[grib] category=\(category), value=\(infoObj["obsrValue"])")
            let value: Double! = (infoObj["obsrValue"] as! Double)
//            NSLog("[grib] category=\(category as! String), value=\(value as! String)")

            
            switch category {
            case "T1H": // T1H: 기온
                gribVO.T1H = value
                NSLog("gribVO.T1H=\(gribVO.T1H!)")
            case "RN1": // RN1: 1시간 강수량:
                gribVO.RN1 = value
                 NSLog("gribVO.RN1=\(gribVO.RN1!)")
            case "PTY": // PTY: 강수형태:
                gribVO.PTY = value
                 NSLog("gribVO.PTY=\(gribVO.PTY!)")
            default:
                ()
            }
        }
        gribVO.isComplete = true
        
        self.viewWeatherInfo()
    } // func printWeatherGribInfo()
    
    
    // 초단기예보 출력.
    func printWeatherTimeInfo(_ timeObj:[String: Any]){
        let response = timeObj["response"] as! [String : Any]
        let header = response["header"] as! [String : Any]
        let body = response["body"] as! [String : Any]
        
        let resultCode = header["resultCode"] as! String
        let totalCount = body["totalCount"] as! Int
        NSLog("[time] resultCode=\(resultCode)")
        NSLog("[time] totalCount=\(totalCount)")
        
        guard resultCode == Constant.KMA_SUCCESS_CODE && totalCount > 0 else {
            NSLog("[time] guard return : resultCode=\(resultCode), totalCount=\(totalCount)")
            return
        }
        
        let items = (body["items"] as! [String : Any])
        let item = items["item"] as! [Any]
        var standardTime: String? = nil
        
        for i in item {
            let infoObj = i as! [String : Any]
            let category: String! = (infoObj["category"] as! String)
            let value: Double! = (infoObj["fcstValue"] as! Double)
            let time: String! = "\(infoObj["fcstTime"]!)"
            
            NSLog("[time] category=\(category!), value=\(value!), time=\(time!)")
            
            if standardTime == nil {
                standardTime = time
                NSLog("standardTime=\(standardTime!)")
                
            } else if Int(standardTime!)! > Int(time!)! {
                NSLog("######### 에러 ########### \(Int(standardTime!)!)   \(time!)")
                NSLog("######### 에러 ########### \(Int(standardTime!)!)   \(time!)")
            }
            
//            let currTime = "\(Utils.getTime(dateFormat: "HH"))00"
//            if currTime != time! {
            if standardTime != time! {
//                NSLog("\(currTime) != \(time!) => continue")
                continue
            }
            
//            NSLog("[time] category=\(category), value=\(value), time=\(time)")
            
            switch category {
            case "T1H": // T1H: 기온
                timeVO.T1H = value
                NSLog("timeVO.T1H=\(timeVO.T1H!)")
            case "RN1": // RN1: 1시간 강수량:
                timeVO.RN1 = value
                NSLog("timeVO.RN1=\(timeVO.RN1!)")
            case "PTY": // PTY: 강수형태:
                timeVO.PTY = value
                NSLog("timeVO.PTY=\(timeVO.PTY!)")
            case "SKY": // PTY: 강수형태:
                timeVO.SKY = value
                NSLog("timeVO.SKY=\(timeVO.SKY!)")
            default:
                ()
            }
        }
        timeVO.isComplete = true
        
        self.viewWeatherInfo()
    } // func printWeatherTimeInfo()
    
    // 동네예보 출력.
    func printWeatherSpaceInfo(_ spaceObj:[String: Any]){
        let response = spaceObj["response"] as! [String : Any]
        let header = response["header"] as! [String : Any]
        let body = response["body"] as! [String : Any]
        
        let resultCode = header["resultCode"] as! String
        let totalCount = body["totalCount"] as! Int
        NSLog("resultCode=\(resultCode)")
        NSLog("totalCount=\(totalCount)")
        
        guard resultCode == Constant.KMA_SUCCESS_CODE && totalCount > 0 else {
            NSLog("guard return(printWeatherGribInfo) : resultCode=\(resultCode), totalCount=\(totalCount)")
            return
        }
        
        let items = (body["items"] as! [String : Any])
        let item  = items["item"] as! [Any]
        
        var spaceKeyArray = [String]()
        var spaceDataDict = [String: Dictionary<String, Any>]()
        for info in item {
            let infoObj = info as! [String : Any]
            let category: String! = (infoObj["category"] as! String)
            let value = infoObj["fcstValue"] as! Double
            let date: String! = "\(infoObj["fcstDate"]!)"
            let time: String! = "\(infoObj["fcstTime"]!)"
            let dictKey: String! = "\(date!)_\(time!)"
            
            let currDateTime = Int("\(utils.getToday(dateFormat: "yyyyMMddHHmm"))")
            let spaceDateTime = Int("\(date!)\(time!)")
            
            if currDateTime! > spaceDateTime! {
                continue
            }
            
            if spaceKeyArray.contains(dictKey) == false {
                spaceKeyArray.append(dictKey)
                spaceDataDict[dictKey] = [String: Double]()
            }
            (spaceDataDict[dictKey])?[category] = value
        }
        NSLog("spaceDictionary=\(spaceDataDict)")
        for dateTime in spaceKeyArray {
            NSLog("dateTime=\(dateTime)")
        }

        spaceVO.spaceKeyArray = spaceKeyArray
        spaceVO.spaceDataDictionary = spaceDataDict
        spaceVO.isComplete = true
        
        // 하늘상태 출력
        self.viewSpaceInfo()
        
    } // func printWeatherSpaceInfo()

    
    // 시간별 예보 출력(3시간단위)
    func viewSpaceInfo() {
        NSLog("viewSpaceInfo start")
        
        let dateLabelY:CGFloat = 10 // 날짜
        let timeLabelY:CGFloat = 30 // 시간
        let skyImageY:CGFloat = 73 // 날씨
        let tempLabelY:CGFloat = 120 // 기온
        let rainProLabelY:CGFloat = 150 // 강수확률
        let rainLabelY:CGFloat = 180 // 강수량
        let humLabelY:CGFloat = 210 // 습도
        let windWayLabelY:CGFloat = 240 // 풍향
        let windSpeedLabelY:CGFloat = 270 // 풍속
        
        // 헤더영역 뷰.
        let timeInfoView = UIView()
        timeInfoView.frame = CGRect(x: 10, y: 10, width: 50, height: Int(todayWeatherTimeScrollAreaView.frame.height))
        
        let dateLabel = UILabel()
        dateLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
        dateLabel.text = "날짜"
        dateLabel.textColor = fontColor
        dateLabel.sizeToFit()
        dateLabel.center = CGPoint(x: timeInfoView.frame.width/2, y: dateLabelY)
        
        
        let timeLabel = UILabel()
        timeLabel.frame = CGRect(x: 0, y: 15, width: 50, height: 20)
        timeLabel.text = "시간"
        timeLabel.textColor = fontColor
        timeLabel.sizeToFit()
        timeLabel.center = CGPoint(x: timeInfoView.frame.width/2, y: timeLabelY)
        
        
        let skyImageLabel = UILabel()
        skyImageLabel.frame = CGRect(x: 0, y: 15, width: 50, height: 20)
        skyImageLabel.text = "날씨"
        skyImageLabel.textColor = fontColor
        skyImageLabel.sizeToFit()
        skyImageLabel.center = CGPoint(x: timeInfoView.frame.width/2, y: skyImageY)
        
        
        let tempLabel = UILabel()
        tempLabel.frame = CGRect(x: 0, y: 15, width: 50, height: 20)
        tempLabel.text = "기온"
        tempLabel.textColor = fontColor
        tempLabel.sizeToFit()
        tempLabel.center = CGPoint(x: timeInfoView.frame.width/2, y: tempLabelY)
        
        
        let rainProLabel = UILabel()
        rainProLabel.frame = CGRect(x: 0, y: 15, width: 50, height: 20)
        rainProLabel.text = "강수확률"
        rainProLabel.textColor = fontColor
        rainProLabel.sizeToFit()
        rainProLabel.center = CGPoint(x: timeInfoView.frame.width/2, y: rainProLabelY)
        
        
        let rainLabel = UILabel()
        rainLabel.frame = CGRect(x: 0, y: 15, width: 50, height: 20)
        rainLabel.text = "강수량"
        rainLabel.textColor = fontColor
        rainLabel.sizeToFit()
        rainLabel.center = CGPoint(x: timeInfoView.frame.width/2, y: rainLabelY)
        
        
        let humLabel = UILabel()
        humLabel.frame = CGRect(x: 0, y: 15, width: 50, height: 20)
        humLabel.text = "습도"
        humLabel.textColor = fontColor
        humLabel.sizeToFit()
        humLabel.center = CGPoint(x: timeInfoView.frame.width/2, y: humLabelY)
        
        
        let windWayLabel = UILabel()
        windWayLabel.frame = CGRect(x: 0, y: 15, width: 50, height: 20)
        windWayLabel.text = "풍향"
        windWayLabel.textColor = fontColor
        windWayLabel.sizeToFit()
        windWayLabel.center = CGPoint(x: timeInfoView.frame.width/2, y: windWayLabelY)
        
        
        let windSpeedLabel = UILabel()
        windSpeedLabel.frame = CGRect(x: 0, y: 15, width: 50, height: 20)
        windSpeedLabel.text = "풍속"
        windSpeedLabel.textColor = fontColor
        windSpeedLabel.sizeToFit()
        windSpeedLabel.center = CGPoint(x: timeInfoView.frame.width/2, y: windSpeedLabelY)
        
        
        timeInfoView.addSubview(dateLabel)
        timeInfoView.addSubview(timeLabel)
        timeInfoView.addSubview(skyImageLabel)
        timeInfoView.addSubview(tempLabel)
        timeInfoView.addSubview(rainProLabel)
        timeInfoView.addSubview(rainLabel)
        timeInfoView.addSubview(humLabel)
        timeInfoView.addSubview(windWayLabel)
        timeInfoView.addSubview(windSpeedLabel)
        
        todayWeatherTimeScrollAreaView.addSubview(timeInfoView)
        
        
        
        
        var cnt = 1;
        var prevDateStr:String! = ""; // 이전날짜(비교값)
        var currDateStr:String! = ""; // 지금날짜(비교값)
        var dateLabelText:String! // 날짜
        for key in spaceVO.spaceKeyArray {
            var info: Dictionary<String, Any> = spaceVO.spaceDataDictionary[key]!
            
            let dateRange = key.index(key.startIndex, offsetBy: 0)..<key.index(key.startIndex, offsetBy: 8)
            currDateStr   = "\(key[dateRange])" // 날짜정보 취득
            
            // 이전값과 지금값을 비교한다.
            //      다를경우 날짜출력.
            //      같을경우 - 출력
            if(prevDateStr == nil || prevDateStr != currDateStr!){
                prevDateStr = currDateStr
                dateLabelText = "\(utils.getWeekDay(dateStr: currDateStr!))"
            } else {
                dateLabelText = "-";
            }
            
            
            let timeInfoView = UIView()
            timeInfoView.frame = CGRect(x: (88 * cnt), y: 10, width: 50, height: Int(todayWeatherTimeScrollAreaView.frame.height))
            
            
            let dateLabel = UILabel()
            dateLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
            dateLabel.text = dateLabelText
            dateLabel.textColor = fontColor
            dateLabel.sizeToFit()
            dateLabel.center = CGPoint(x: timeInfoView.frame.width/2, y: dateLabelY)
            

            let timeHourRange = key.index(key.startIndex, offsetBy: 9)..<key.index(key.startIndex, offsetBy: 11)
            let timeMinuteRange = key.index(key.startIndex, offsetBy: 11)..<key.index(key.startIndex, offsetBy: 13)
            let hour = "\(key[timeHourRange])";
            let minute = "\(key[timeMinuteRange])"
            let timeLabel = UILabel()
            timeLabel.frame = CGRect(x: 0, y: 15, width: 50, height: 20)
            timeLabel.text = "\(hour):\(minute)"
            timeLabel.textColor = fontColor
            timeLabel.sizeToFit()
            timeLabel.center = CGPoint(x: timeInfoView.frame.width/2, y: timeLabelY)
            
            let PTY:Int = Int(info["PTY"] as! Double)
            let SKY:Int = Int(info["SKY"] as! Double)
            let skyImageName = utils.getSkyImageName(RN1: 0.0, PTY: PTY, SKY: SKY, TIME:Int("\(hour)\(minute)")!)
            
            let skyImage = UIImageView()
            skyImage.frame = CGRect(x: 0, y: 15, width: 35, height: 35)
            skyImage.center = CGPoint(x: timeInfoView.frame.width/2, y: skyImageY)
            skyImage.image = UIImage(named: skyImageName)
            
            
            let tempLabel = UILabel()
            tempLabel.frame = CGRect(x: 0, y: 15, width: 50, height: 20)
            tempLabel.text = "\(info["T3H"] ?? "")℃" // 기온
            tempLabel.textColor = fontColor
            tempLabel.sizeToFit()
            tempLabel.center = CGPoint(x: timeInfoView.frame.width/2, y: tempLabelY)
            
            
            let rainPro:Double = (info["POP"] ?? "0.0") as! Double
            let rainProLabel = UILabel()
            rainProLabel.frame = CGRect(x: 0, y: 15, width: 50, height: 20)
            rainProLabel.text = "\(Int(rainPro))%" // 강수확률
            rainProLabel.textColor = fontColor
            rainProLabel.sizeToFit()
            rainProLabel.center = CGPoint(x: timeInfoView.frame.width/2, y: rainProLabelY)
            
            
            let rain: String!
            if info["R06"] == nil {
                rain = "-"
            } else {
                rain = "\(Int((info["R06"] ?? "0.0") as! Double))mm"
            }
            let rainLabel = UILabel()
            rainLabel.frame = CGRect(x: 0, y: 15, width: 50, height: 20)
            rainLabel.text = "\(rain!)" // 강수량
            rainLabel.textColor = fontColor
            rainLabel.sizeToFit()
            rainLabel.center = CGPoint(x: timeInfoView.frame.width/2, y: rainLabelY)
            
            
            let hum:Double = (info["REH"] ?? "0.0") as! Double
            let humLabel = UILabel()
            humLabel.frame = CGRect(x: 0, y: 15, width: 50, height: 20)
            humLabel.text = "\(Int(hum))%" // 습도
            humLabel.textColor = fontColor
            humLabel.sizeToFit()
            humLabel.center = CGPoint(x: timeInfoView.frame.width/2, y: humLabelY)
            
            
            let windWayDouble = (info["REH"] ?? "0.0") as! Double
            let windWay:String = utils.getWindWay(windWayDouble)
            let windWayLabel = UILabel()
            windWayLabel.frame = CGRect(x: 0, y: 15, width: 50, height: 20)
            windWayLabel.text = windWay // 풍향
            windWayLabel.textColor = fontColor
            windWayLabel.sizeToFit()
            windWayLabel.center = CGPoint(x: timeInfoView.frame.width/2, y: windWayLabelY)
            
            
            let windSpeedLabel = UILabel()
            windSpeedLabel.frame = CGRect(x: 0, y: 15, width: 50, height: 20)
            windSpeedLabel.text = "\(info["WSD"] ?? "")m/s" // 풍속
            windSpeedLabel.textColor = fontColor
            windSpeedLabel.sizeToFit()
            windSpeedLabel.center = CGPoint(x: timeInfoView.frame.width/2, y: windSpeedLabelY)
            
            
            timeInfoView.addSubview(dateLabel)
            timeInfoView.addSubview(timeLabel)
            timeInfoView.addSubview(skyImage)
            timeInfoView.addSubview(tempLabel)
            timeInfoView.addSubview(rainProLabel)
            timeInfoView.addSubview(rainLabel)
            timeInfoView.addSubview(humLabel)
            timeInfoView.addSubview(windWayLabel)
            timeInfoView.addSubview(windSpeedLabel)
            
            todayWeatherTimeScrollAreaView.addSubview(timeInfoView)
            
            cnt = cnt + 1
        }
        
        
        todayWeatherTimeScrollAreaView.contentSize = CGSize(width: CGFloat(cnt * 87), height: todayWeatherTimeScrollAreaView.frame.height)
        todayWeatherTimeScrollAreaView.decelerationRate = UIScrollView.DecelerationRate.normal; // 스크롤속도
        
        self.viewWeatherInfo()
    }
    
    // 지역, 시간정보 출력
    func showLocationInfo(){
        if self.areaVO.dong != nil && self.gribVO.T1H != nil {
            self.locationInfo.font = UIFont.boldSystemFont(ofSize: 25)
            self.locationInfo.textAlignment = .center
            self.locationInfo.text = " \(self.areaVO.dong!),\u{00A0}\u{00A0}\(self.gribVO.T1H!)℃       "
            self.locationInfo.textColor = fontColor
            self.locationInfo.sizeToFit()
            self.locationInfo.center = CGPoint(x: weatherIconAreaView.frame.size.width/2, y: locationInfo.frame.origin.y + locationInfo.frame.height/2)
        }
    }
    
    // 현재 기상정보 출력
    func viewWeatherInfo(){
        NSLog("timeVO.isComplete=\(timeVO.isComplete), gribVO.isComplete=\(gribVO.isComplete), spaceVO.isComplete=\(spaceVO.isComplete), airVO.isComplete=\(airVO.isComplete)")
        guard timeVO.isComplete && gribVO.isComplete && spaceVO.isComplete && airVO.isComplete && weekVO.isWeekComplete else {
            return
        }
        
        // 위치, 기온정보 출력
        self.showLocationInfo()
        
        // 하늘상태 출력
        self.showTodayWeatherSkyInfo()

        // 주간예보 출력
        self.showWeekWeatherInfo()
        
        // 뷰 출력
        self.changeView()
    }
    
    func showTodayWeatherSkyInfo() {
        
//        if Constant.IS_TEST {
//            self.timeVO.SKY = 4.0
//        }
        
        let skyImageName = utils.getSkyImageName(RN1: gribVO.RN1!, PTY: Int(self.gribVO.PTY), SKY: Int(self.timeVO.SKY), TIME: Int(utils.getTime())!)
        self.skyImage.image = UIImage(named: skyImageName)
        
    } // func showTodayWeatherSkyInfo()
    
    
    
    
    // 네트워크 연결상태 취득.
    func connectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        return ret
    }
    
    
    @objc
    func moveLicencePage1(sender:UITapGestureRecognizer){
        self.pageOpen(openURL: "https://www.flaticon.com/authors/iconixar")
    }
    
    @objc
    func moveLicencePage2(sender:UITapGestureRecognizer){
        self.pageOpen(openURL: "https://www.flaticon.com")
    }
    
    @objc
    func moveLicencePage3(sender:UITapGestureRecognizer){
        self.pageOpen(openURL: "http://creativecommons.org/licenses/by/3.0/")
    }
    
    func pageOpen(openURL: String){
        guard let url = URL(string: openURL), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    
    func getStationTMXYInfo(){
        let escapedString = "\(self.areaVO.sido+" "+self.areaVO.gu)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let TM_XY_URL = "\(Constant.TM_XY_URL)&umdName=\(escapedString!)"
        NSLog("getAirInfo call - \(TM_XY_URL)")
        let parser = XMLParser(contentsOf: URL(string: TM_XY_URL)!)
        parser?.delegate = self
        parser?.parse()
        NSLog("tmX=\(self.areaVO.tmX), tmY=\(self.areaVO.tmY)")
        
        self.getStationName()
    }
    
    func getStationName(){
        let STATION_NM_URL = "\(Constant.STATION_NM_URL)&tmX=\(self.areaVO.tmX)&tmY=\(self.areaVO.tmY)"
        NSLog("getAirInfo call - \(STATION_NM_URL)")
        let parser = XMLParser(contentsOf: URL(string: STATION_NM_URL)!)
        parser?.delegate = self
        parser?.parse()
        NSLog("stationName=\(self.areaVO.stationName!)")
        
        self.getAirInfo()
    }
    
    // 공기정보 취득.
    func getAirInfo(){
        let escapedString = "\(self.areaVO.stationName ?? "")".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let AIR_INFO_URL = "\(Constant.AIR_INFO_URL)&numOfRows=1&pageNo=1&stationName=\(escapedString ?? "")&dataTerm=DAILY&ver=1.3"
        NSLog("getAirInfo call - \(AIR_INFO_URL)")
        let parser = XMLParser(contentsOf: URL(string: AIR_INFO_URL)!)
        parser?.delegate = self
        parser?.parse()
        
        self.viewAirInfo()
    }
    
    func viewAirInfo(){
        
        /// 공기 정보 타이틀
        let airAreaTitleFont = UIFont.boldSystemFont(ofSize: 20)
        let airAreaGradeFont = UIFont.systemFont(ofSize: 18)
        
        let airAreaYInterval:CGFloat = 35
        let airAreaTitleY:CGFloat = 30
        let airAreaValueY:CGFloat = airAreaTitleY + airAreaYInterval
        let airAreaGradeY:CGFloat = airAreaValueY + airAreaYInterval
        let airAreaCommentY:CGFloat = airAreaGradeY + 46
        
        // 미세먼지
        let airAreaFineDustX:CGFloat = screenWidth/5
        
        
        
        fineDustTitle.frame = CGRect(x: 0, y: 0, width: 200, height: 25)
        fineDustTitle.text = "미세먼지"
        fineDustTitle.textColor = fontColor
        fineDustTitle.textAlignment = .center
        fineDustTitle.font = airAreaTitleFont
        fineDustTitle.sizeToFit()
        fineDustTitle.center = CGPoint(x: airAreaFineDustX, y: airAreaTitleY)
        
        
        fineDustValue.frame = CGRect(x: 0, y: 0, width: 200, height: 25)
        fineDustValue.text = self.airVO.pm10Value + "㎍/㎥"
        fineDustValue.textColor = fontColor
        fineDustValue.textAlignment = .center
        fineDustValue.sizeToFit()
        fineDustValue.center = CGPoint(x: airAreaFineDustX, y: airAreaValueY)
        
        
        fineDustGrade.frame = CGRect(x: 0, y: 0, width: 200, height: 25)
        fineDustGrade.text = getGradeNm(self.airVO.pm10Grade1h)
        fineDustGrade.textColor = fontColor
        fineDustGrade.textAlignment = .center
        fineDustGrade.font = airAreaGradeFont
        fineDustGrade.sizeToFit()
        fineDustGrade.center = CGPoint(x: airAreaFineDustX, y: airAreaGradeY)
        
        
        // 초미세먼지
        let airAreaUltraDustX:CGFloat = screenWidth/2
        ultrafineDustTitle.frame = CGRect(x: 0, y: 0, width: 200, height: 25)
        ultrafineDustTitle.text = "초미세먼지"
        ultrafineDustTitle.textColor = fontColor
        ultrafineDustTitle.textAlignment = .center
        ultrafineDustTitle.font = airAreaTitleFont
        ultrafineDustTitle.sizeToFit()
        ultrafineDustTitle.center = CGPoint(x: airAreaUltraDustX, y: airAreaTitleY)
        
        
        ultrafineDustValue.frame = CGRect(x: 0, y: 0, width: 200, height: 25)
        ultrafineDustValue.text = self.airVO.pm25Value + "㎍/㎥"
        ultrafineDustValue.textColor = fontColor
        ultrafineDustValue.textAlignment = .center
        ultrafineDustValue.sizeToFit()
        ultrafineDustValue.center = CGPoint(x: airAreaUltraDustX, y: airAreaValueY)
        
        
        ultrafineDustGrade.frame = CGRect(x: 0, y: 0, width: 200, height: 25)
        ultrafineDustGrade.text = getGradeNm(self.airVO.pm25Grade1h)
        ultrafineDustGrade.textColor = fontColor
        ultrafineDustGrade.textAlignment = .center
        ultrafineDustGrade.font = airAreaGradeFont
        ultrafineDustGrade.sizeToFit()
        ultrafineDustGrade.center = CGPoint(x: airAreaUltraDustX, y: airAreaGradeY)
        
        
        // 오존
        let airAreaOzoneX:CGFloat = screenWidth/2 + screenWidth/3.5
        
        ozoneTitle.frame = CGRect(x: 0, y: 0, width: 200, height: 25)
        ozoneTitle.text = "오존"
        ozoneTitle.textColor = fontColor
        ozoneTitle.textAlignment = .center
        ozoneTitle.font = airAreaTitleFont
        ozoneTitle.sizeToFit()
        ozoneTitle.center = CGPoint(x: airAreaOzoneX, y: airAreaTitleY)
        
        
        ozoneValue.frame = CGRect(x: 0, y: 0, width: 200, height: 25)
        ozoneValue.text = self.airVO.o3Value + "ppm"
        ozoneValue.textColor = fontColor
        ozoneValue.textAlignment = .center
        ozoneValue.sizeToFit()
        ozoneValue.center = CGPoint(x: airAreaOzoneX, y: airAreaValueY)
        
        
        ozoneGrade.frame = CGRect(x: 0, y: 0, width: 200, height: 25)
        ozoneGrade.text = getGradeNm(self.airVO.o3Grade)
        ozoneGrade.textAlignment = .center
        ozoneGrade.textColor = fontColor
        ozoneGrade.font = airAreaGradeFont
        ozoneGrade.sizeToFit()
        ozoneGrade.center = CGPoint(x: airAreaOzoneX, y: airAreaGradeY)
        
        
        airCommentLabel.frame = CGRect(x: 0, y: 0, width: airAreaView.frame.width, height: 25)
        airCommentLabel.text = self.getAirComment()
        airCommentLabel.textColor = fontColor
        airCommentLabel.textAlignment = .center
        airCommentLabel.font = UIFont.systemFont(ofSize: 18)
        airCommentLabel.sizeToFit()
        airCommentLabel.center = CGPoint(x: screenWidth/2.05, y: airAreaCommentY)
        
        airAreaView.addSubview(fineDustTitle)
        airAreaView.addSubview(fineDustValue)
        airAreaView.addSubview(fineDustGrade)
        
        airAreaView.addSubview(ultrafineDustTitle)
        airAreaView.addSubview(ultrafineDustValue)
        airAreaView.addSubview(ultrafineDustGrade)
        
        airAreaView.addSubview(ozoneTitle)
        airAreaView.addSubview(ozoneValue)
        airAreaView.addSubview(ozoneGrade)
        
        airAreaView.addSubview(airCommentLabel)
        
        self.airVO.isComplete = true;
        
        self.viewWeatherInfo();
    }
    
    func getGradeNm(_ grade: String) -> String{
        if grade == "1" {
            return "좋음"
        } else if grade == "2" {
            return "보통"
        } else if grade == "3" {
            return "나쁨"
        } else {
            return "매우나쁨"
        }
    }
    
    func getAirComment() -> String {
        var returnMsg:String! = "";
        
        //        if Constant.IS_TEST {
        //            self.airVO.pm10Grade1h = "4"
        //            self.airVO.pm25Grade1h = "4"
        //            self.airVO.o3Grade = "4"
        //        }
        
        
        if self.airVO.pm10Grade1h == "4" || self.airVO.pm25Grade1h == "4" || self.airVO.o3Grade == "4" {
            mainGradientLayer.colors = [
                UIColor(red:0.89, green:0.29, blue:0.29, alpha:1.0).cgColor, // Top
                UIColor(red:0.42, green:0.16, blue:0.21, alpha:1.0).cgColor // Bottom
            ]
            mainGradientLayer.locations = [0, 0.8, 1]
            returnMsg = "실외활동 NONO!!ㅠㅠ 실내생활하세요!"
            
        } else if self.airVO.pm10Grade1h == "3" || self.airVO.pm25Grade1h == "3" || self.airVO.o3Grade == "3" {
            mainGradientLayer.colors = [
                UIColor(red:0.72, green:0.72, blue:0.56, alpha:1.0).cgColor, // Top
                UIColor(red:0.68, green:0.56, blue:0.41, alpha:1.0).cgColor // Bottom
            ]
            mainGradientLayer.locations = [0, 0.9, 1]
            returnMsg = "장시간 무리한 실외활동을 조심하세요!!"
            
        } else if self.airVO.pm10Grade1h == "2" || self.airVO.pm25Grade1h == "2" || self.airVO.o3Grade == "2" {
            mainGradientLayer.colors = [
                UIColor(red:0.36, green:0.86, blue:0.56, alpha:1.0).cgColor, // Top
                UIColor(red:0.21, green:0.68, blue:0.60, alpha:1.0).cgColor
            ]
            mainGradientLayer.locations = [0, 0.6, 1]
            returnMsg = "실외활동 가능하나 몸 상태에 따라 유의하세요!"
            
        } else {
            mainGradientLayer.colors = [
                UIColor(red:0.40, green:0.72, blue:0.95, alpha:1.0).cgColor, // Top
                UIColor(red:0.31, green:0.41, blue:0.80, alpha:1.0).cgColor // Bottom
            ]
            mainGradientLayer.locations = [0, 0.9, 1]
            returnMsg = "야호!! 좋은날씨예요!!!!"
        }
        mainGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        mainGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        
        return returnMsg
    }
    
}






// XML파싱
extension ForecastMainVC: XMLParserDelegate{
    
    // XMLParserDelegate 함수
    // XML 파서가 시작 테그를 만나면 호출됨
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
    }
    
    // XML 파서가 종료 테그를 만나면 호출됨
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?){
    }
    
    // 현재 테그에 담겨있는 문자열 전달
    public func parser(_ parser: XMLParser, foundCharacters value: String) {
        guard value.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            return;
        }
        if (currentElement == "tmX") {
            self.areaVO.tmX = (value as NSString).doubleValue
            
        } else if (currentElement == "tmY") {
            self.areaVO.tmY = (value as NSString).doubleValue
            
        } else if (currentElement == "stationName" && self.areaVO.stationName=="" ){
            self.areaVO.stationName = value;
            
        } else if (currentElement == "o3Value") {
            self.airVO.o3Value = "\(value)"
            
        } else if (currentElement == "pm10Value") {
            self.airVO.pm10Value = "\(value)"
            
        } else if (currentElement == "pm25Value") {
            self.airVO.pm25Value = "\(value)"
            
        } else if (currentElement == "o3Grade") {
            self.airVO.o3Grade = "\(value)"
            
        } else if (currentElement == "pm10Grade1h") {
            self.airVO.pm10Grade1h = "\(value)"
            
        } else if (currentElement == "pm25Grade1h") {
            self.airVO.pm25Grade1h = "\(value)"
            
        } else if (currentElement == "taMax3") {
            self.weekVO.taMax3 = "\(value)"
        } else if (currentElement == "taMax4") {
            self.weekVO.taMax4 = "\(value)"
        } else if (currentElement == "taMax5") {
            self.weekVO.taMax5 = "\(value)"
        } else if (currentElement == "taMax6") {
            self.weekVO.taMax6 = "\(value)"
        } else if (currentElement == "taMax7") {
            self.weekVO.taMax7 = "\(value)"
        } else if (currentElement == "taMax8") {
            self.weekVO.taMax8 = "\(value)"
        } else if (currentElement == "taMax9") {
            self.weekVO.taMax9 = "\(value)"
        } else if (currentElement == "taMax10") {
            self.weekVO.taMax10 = "\(value)"
        } else if (currentElement == "taMin3") {
            self.weekVO.taMin3 = "\(value)"
        } else if (currentElement == "taMin4") {
            self.weekVO.taMin4 = "\(value)"
        } else if (currentElement == "taMin5") {
            self.weekVO.taMin5 = "\(value)"
        } else if (currentElement == "taMin6") {
            self.weekVO.taMin6 = "\(value)"
        } else if (currentElement == "taMin7") {
            self.weekVO.taMin7 = "\(value)"
        } else if (currentElement == "taMin8") {
            self.weekVO.taMin8 = "\(value)"
        } else if (currentElement == "taMin9") {
            self.weekVO.taMin9 = "\(value)"
        } else if (currentElement == "taMin10") {
            self.weekVO.taMin10 = "\(value)"
        } else if (currentElement == "wf3Am") {
            self.weekVO.wf3Am = "\(value)"
        } else if (currentElement == "wf4Am") {
            self.weekVO.wf4Am = "\(value)"
        } else if (currentElement == "wf5Am") {
            self.weekVO.wf5Am = "\(value)"
        } else if (currentElement == "wf6Am") {
            self.weekVO.wf6Am = "\(value)"
        } else if (currentElement == "wf7Am") {
            self.weekVO.wf7Am = "\(value)"
        } else if (currentElement == "wf3Pm") {
            self.weekVO.wf3Pm = "\(value)"
        } else if (currentElement == "wf4Pm") {
            self.weekVO.wf4Pm = "\(value)"
        } else if (currentElement == "wf5Pm") {
            self.weekVO.wf5Pm = "\(value)"
        } else if (currentElement == "wf6Pm") {
            self.weekVO.wf6Pm = "\(value)"
        } else if (currentElement == "wf7Pm") {
            self.weekVO.wf7Pm = "\(value)"
        } else if (currentElement == "wf8") {
            self.weekVO.wf8 = "\(value)"
        } else if (currentElement == "wf9") {
            self.weekVO.wf9 = "\(value)"
        } else if (currentElement == "wf10") {
            self.weekVO.wf10 = "\(value)"
        }
    }
}

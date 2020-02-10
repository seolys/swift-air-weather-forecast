//
//  AreaSelectVC.swift
//  Air-Weather-Forecast
//
//  Created by seol on 06/06/2019.
//  Copyright © 2019 seol. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

class AreaSelectVC: UIViewController, CLLocationManagerDelegate {
    let utils = Utils()
    
    @IBOutlet var areaName: UITextField!
    
    var locationManager:CLLocationManager! = CLLocationManager()
    var areaX:Double! = 0.0
    var areaY:Double! = 0.0
    var isAreaInit:Bool = false
    
    override func viewDidLoad() {
        NSLog("AreaSelectVC - viewDidLoad")
        super.viewDidLoad()
        self.loadAreaInfo();
    }
    
    // 위도, 경도정보 취득
    func loadAreaInfo() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        // 사전동의가 되어있을때.
        if let coor = locationManager.location?.coordinate {
            print("locationManager.location?.coordinate=\(locationManager.location?.coordinate)")
            print("latitude=\(coor.latitude), longtitude=\(coor.longitude)")
            
            var latitude:Double = 0
            var longtitude:Double = 0
            if Constant.IS_TEST {
                latitude = 37.49162880006584
                longtitude = 126.88916194362048
            } else {
                latitude = Double(coor.latitude)
                longtitude = Double(coor.longitude)
            }
            
            self.latLongToXY(latitude, longtitude)
            self.isAreaInit = true
        }
    }
    
    // (사전동의가 뒤늦게 되었을때) 위도, 경도 취득.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard self.isAreaInit == false else {
            return
        }
        NSLog("AreaSelectVC - didUpdateLocations")
        
        var latitude:Double = 0
        var longtitude:Double = 0
        if Constant.IS_TEST {
            latitude = 37.49162880006584
            longtitude = 126.88916194362048
        } else {
            let latestLocation: AnyObject = locations[locations.count - 1]
            latitude = Double(latestLocation.coordinate.latitude)
            longtitude = Double(latestLocation.coordinate.longitude)
        }
        
        self.latLongToXY(latitude, longtitude)
        self.isAreaInit = true
    }
    
    // 위도, 경도를 기상청 좌표로 변환한다.
    func latLongToXY(_ lat:Double, _ long:Double){
        let mapInfo = utils.latLongToXY(lat, long)
        self.areaX = mapInfo["x"]
        self.areaY = mapInfo["y"]
        print("x=\(String(areaX)), y=\(String(areaY))")
        
        // 기상청좌표로 지역명을 조회한다.
        selectAreaName()
    }
    
    // 기상청좌표로 지역명 조회.
    func selectAreaName(){
        // DB에서 지역명 조회처리.
        
        self.areaName.text = "구로동"
    }
    
    // 저장 후 기상정보 화면 이동.
    @IBAction func save(_ sender: Any) {
        let ud = UserDefaults.standard
        ud.set(self.areaName.text, forKey: Constant.AREA_NAME)
        ud.set(Int(self.areaX), forKey: Constant.AREA_X)
        ud.set(Int(self.areaY), forKey: Constant.AREA_Y)
        ud.set(true, forKey: Constant.IS_AREA_SELECT)
        ud.synchronize()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    

}

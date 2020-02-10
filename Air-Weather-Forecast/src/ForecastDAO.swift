import FMDB

class ForecastDAO {
    
    lazy var fmdb: FMDatabase! = {
        // 1. 파일매니저 객체를 생성
        let fileMgr = FileManager.default
        
        // 2. 샌드박스 내 문서 디레거리에서 데이터베이스 파일 경로를 확인
        let docPath = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = docPath.appendingPathComponent("weather.sqlite").path
        
        // 3. 샌드박스 경로에 파일이 없다면 메인 번들에 만들어 둔 hr.sqlite를 가져와 복사
        if fileMgr.fileExists(atPath: dbPath) == false {
            let dbSource = Bundle.main.path(forResource: "weather", ofType: "sqlite")
            try! fileMgr.copyItem(atPath: dbSource!, toPath: dbPath)
        }
        
        // 4. 준비된 데이터베이스 파일을 바탕으로 FMDatabase 객체를 생성
        let db = FMDatabase(path: dbPath)
        return db
    }()
    
    init() {
        self.fmdb.open()
    }
    deinit {
        self.fmdb.close()
    }
    
    func selectTodayArea(X:Int, Y:Int) -> AreaVO {
        // 반환할 데이터를 담을 [TodoData]타입 객체를 정의
        let areaVO = AreaVO()
        
        do {
            let sql = """
                SELECT
                    SIDO, GU, DONG, X, Y, GION, YEBO
                FROM
                    TB_WEATHER_AREA_INFO
                WHERE
                    X = ?
                AND Y = ?
            """
            
            let rs = try self.fmdb.executeQuery(sql, values: [X, Y])
            while rs.next() {
                areaVO.sido = rs.string(forColumn: "SIDO")
                areaVO.gu = rs.string(forColumn: "GU")
                areaVO.dong = rs.string(forColumn: "DONG")
                areaVO.yeboCode = rs.string(forColumn: "YEBO")
                areaVO.gionCode = rs.string(forColumn: "GION")
//                areaVO.X = rs.string(forColumn: "X")
//                areaVO.Y = rs.string(forColumn: "Y")
            }
        } catch let error as NSError {
            NSLog("error : \(error.localizedDescription)")
        }
        
        return areaVO;
    }
    
}

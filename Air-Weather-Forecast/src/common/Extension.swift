import UIKit

extension UIViewController {
    var areaSelectSB: UIStoryboard {
        return UIStoryboard(name: "AreaSelect", bundle: Bundle.main)
    }
    
    func instanceAreaSelectVC(name: String) -> UIViewController? {
        return self.areaSelectSB.instantiateViewController(withIdentifier: name)
    }
}

extension UIViewController {
    func alert(_ message: String, completion: (()->Void)? = nil) {
        // 메인쓰레드에서 실행되도록 구현
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .cancel, handler: { (_) in
                completion?()
            })
            alert.addAction(okAction)
            self.present(alert, animated: false, completion: nil)
        }
    }
}

extension UIView {
    func fadeTo(_ alpha: CGFloat, duration: TimeInterval = 0.3) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: duration) {
                self.alpha = alpha
            }
        }
    }
    
    func fadeIn(_ duration: TimeInterval = 0.3) {
        fadeTo(1.0, duration: duration)
    }
    
    func fadeOut(_ duration: TimeInterval = 0.3) {
        fadeTo(0.0, duration: duration)
    }
}

import UIKit
import Foundation

extension UIColor {
    class func myCyan () -> UIColor { return UIColor(red: 25/255, green: 181/255, blue: 178/255, alpha: 1) }
    class func myDark () -> UIColor { return UIColor(red: 15/255, green: 20/255, blue: 15/255, alpha: 1) }
    class func myGray () -> UIColor { return UIColor(red: 71/255, green: 71/255, blue: 79/255, alpha: 1) }
     class func myGreen () -> UIColor { return UIColor(red:103/255, green:211/255, blue:141/255, alpha: 1)}
}

extension CGColor {
    class func myCyan () -> CGColor { return UIColor(red: 25/255, green: 181/255, blue: 178/255, alpha: 1).cgColor }
   
}

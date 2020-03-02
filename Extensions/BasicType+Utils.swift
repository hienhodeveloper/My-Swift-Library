import Foundation
import UIKit
import SafariServices

// Ex: let count2 = [1, 2, 3, 4, 5].count { $0 % 2 == 1 }
extension Collection {
    func count(where test: (Element) throws -> Bool) rethrows -> Int {
        return try self.filter(test).count
    }
}

extension SFSafariViewController {
    static func openUrl(_ urlString: String, fromController controller: UIViewController) {
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            controller.present(SFSafariViewController(url: url), animated: true, completion: nil)
        } else if let url = URL(string:"https://" + urlString), UIApplication.shared.canOpenURL(url) {
            controller.present(SFSafariViewController(url: url), animated: true, completion: nil)
        } else if let url = URL(string:"http://" + urlString), UIApplication.shared.canOpenURL(url) {
            controller.present(SFSafariViewController(url: url), animated: true, completion: nil)
        }
    }
}

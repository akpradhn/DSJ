import SwiftUI
import UIKit

enum Branding {
    static let appName = "VaccineVault"
    static var appLogo: Image {
        // Check if AppLogo exists, otherwise use system image to avoid warnings
        if UIImage(named: "AppLogo") != nil {
            return Image("AppLogo")
        } else {
            return Image(systemName: "syringe")
        }
    }
}

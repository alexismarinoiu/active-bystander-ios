import Foundation

private let configuration = UserDefaults.Configuration()

extension UserDefaults {
    static var this: Configuration {
        return configuration
    }

    class Configuration {

        fileprivate init() {}

        private let locationEnabled = "avLocationEnabled"
        private let previouslyLoggedIn = "avPreviouslyLoggedIn"

        var isLocationEnabled: Bool {
            get {
                return UserDefaults.standard.bool(forKey: locationEnabled)
            }

            set {
                UserDefaults.standard.set(newValue, forKey: locationEnabled)
            }
        }

        var hasPreviouslyLoggedIn: Bool {
            get {
                return UserDefaults.standard.bool(forKey: previouslyLoggedIn)
            }

            set {
                UserDefaults.standard.set(newValue, forKey: previouslyLoggedIn)
            }
        }
    }
}

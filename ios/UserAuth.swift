import UIKit

class UserAuth {
    enum Status {
        case loggedOut
        case pendingValidation
        case loggedIn
    }

    private(set) var status: Status = .loggedOut {
        didSet {
            guard oldValue != status else {
                return
            }

            DispatchQueue.main.async { [status] in
                (UIApplication.shared.delegate as? AppDelegate)?
                    .notificationCenter.post(name: .AVAuthStatusChangeNotification,
                                             object: self, userInfo: [0: status])
            }
        }
    }
    internal static var protectionSpace = URLProtectionSpace(host: Environment.endpoint.host!,
                                                            port: 443,
                                                            protocol: Environment.endpoint.scheme!,
                                                            realm: Environment.realm,
                                                            authenticationMethod: NSURLAuthenticationMethodHTTPBasic)
    init() {
        if UserDefaults.this.hasPreviouslyLoggedIn {
            status = .pendingValidation
        }
    }

    func updateStatus(_ completionHandler: ((Status) -> Void)?) {
        status = .pendingValidation

        guard Environment.liveAuth else {
            status = .loggedIn
            completionHandler?(.loggedIn)
            return
        }

        Environment.backend.read(AuthStatusRequest()) { [weak self] (success, response: AuthStatusResponse?) in
            guard success, let response = response, response.status else {
                DispatchQueue.main.async {
                    self?.status = .loggedOut
                    UserDefaults.this.hasPreviouslyLoggedIn = false
                    completionHandler?(.loggedOut)
                }
                return
            }

            DispatchQueue.main.async {
                self?.status = .loggedIn
                UserDefaults.this.hasPreviouslyLoggedIn = true
                completionHandler?(.loggedIn)
            }
        }
    }

    func logIn(with username: String, password: String, completionHandler: ((Status) -> Void)?) {
        let credential = URLCredential(user: username, password: password, persistence: .forSession)
        URLCredentialStorage.shared.setDefaultCredential(credential, for: UserAuth.protectionSpace)
        updateStatus { (status) in
            if status == .loggedIn {
                // Make the credential permanent
                let newCredential = URLCredential(user: username, password: password, persistence: .permanent)
                URLCredentialStorage.shared.setDefaultCredential(newCredential, for: UserAuth.protectionSpace)
            } else {
                // Delete the credential
                URLCredentialStorage.shared.remove(credential, for: UserAuth.protectionSpace)
            }

            completionHandler?(status)
        }
    }

    func logOut() {
        UserDefaults.this.hasPreviouslyLoggedIn = false
        status = .loggedOut
        guard let credential = URLCredentialStorage.shared.defaultCredential(for: UserAuth.protectionSpace) else {
            return
        }

        URLCredentialStorage.shared.remove(credential, for: UserAuth.protectionSpace)
        (UIApplication.shared.delegate as? AppDelegate)?.showLoginViewController()
    }

    func loggedInUser() -> String? {
        return URLCredentialStorage.shared.defaultCredential(for: UserAuth.protectionSpace)?.user
    }
}

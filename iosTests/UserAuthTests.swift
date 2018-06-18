import XCTest
@testable import ios

class UserAuthTests: XCTestCase {

    private var previouslyLoggedIn: Bool = false

    override func setUp() {
        super.setUp()

        previouslyLoggedIn = UserDefaults.this.hasPreviouslyLoggedIn
        UserDefaults.this.hasPreviouslyLoggedIn = false
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        UserDefaults.this.hasPreviouslyLoggedIn = previouslyLoggedIn
    }

    func testStatusUpdateLoggedOutWhenPreviouslyLoggedOut() {
        Environment.backend = TestingBackendService(shouldFailLogin: true)
        let userAuth = UserAuth()

        XCTAssertEqual(userAuth.status, .loggedOut)
        weak var expect = expectation(description: "testStatusUpdateLoggedOutWhenPreviouslyLoggedOut")
        userAuth.updateStatus { (status) in
            guard let expect = expect else {
                XCTFail("Expectation Unavailable")
                return
            }

            XCTAssertEqual(userAuth.status, .loggedOut)
            expect.fulfill()
        }
        XCTAssertEqual(userAuth.status, .pendingValidation)

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStatusUpdateLoggedOutWhenPreviouslyLoggedIn() {
        Environment.backend = TestingBackendService(shouldFailLogin: true)
        UserDefaults.this.hasPreviouslyLoggedIn = true
        let userAuth = UserAuth()

        XCTAssertEqual(userAuth.status, .pendingValidation)
        weak var expect = expectation(description: "testStatusUpdateLoggedOutWhenPreviouslyLoggedIn")
        userAuth.updateStatus { (status) in
            guard let expect = expect else {
                XCTFail("Expectation Unavailable")
                return
            }

            XCTAssertEqual(userAuth.status, .loggedOut)
            expect.fulfill()
        }
        XCTAssertEqual(userAuth.status, .pendingValidation)

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStatusUpdateLoggedInWhenPreviouslyLoggedOut() {
        Environment.backend = TestingBackendService(shouldFailLogin: false)
        let userAuth = UserAuth()

        XCTAssertEqual(userAuth.status, .loggedOut)
        weak var expect = expectation(description: "testStatusUpdateLoggedInWhenPreviouslyLoggedOut")
        userAuth.updateStatus { (status) in
            guard let expect = expect else {
                XCTFail("Expectation Unavailable")
                return
            }

            XCTAssertEqual(userAuth.status, .loggedIn)
            expect.fulfill()
        }
        XCTAssertEqual(userAuth.status, .pendingValidation)

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStatusUpdateLoggedInWhenPreviouslyLoggedIn() {
        Environment.backend = TestingBackendService(shouldFailLogin: false)
        UserDefaults.this.hasPreviouslyLoggedIn = true
        let userAuth = UserAuth()

        XCTAssertEqual(userAuth.status, .pendingValidation)
        weak var expect = expectation(description: "testStatusUpdateLoggedInWhenPreviouslyLoggedIn")
        userAuth.updateStatus { (status) in
            guard let expect = expect else {
                XCTFail("Expectation Unavailable")
                return
            }

            XCTAssertEqual(userAuth.status, .loggedIn)
            expect.fulfill()
        }
        XCTAssertEqual(userAuth.status, .pendingValidation)

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testLogInLogOutCredentialsNotPresentIfFailed() {
        Environment.backend = TestingBackendService(shouldFailLogin: true)
        let userAuth = UserAuth()

        // Log out if the credentials exist
        if let credential = URLCredentialStorage.shared.defaultCredential(for: UserAuth.protectionSpace) {
            URLCredentialStorage.shared.remove(credential, for: UserAuth.protectionSpace)
        }
        // Ensure that credentials are not present
        XCTAssertNil(URLCredentialStorage.shared.defaultCredential(for: UserAuth.protectionSpace))

        weak var expect = expectation(description: "testLogInLogOutCredentialsNotPresentIfFailed")
        userAuth.logIn(with: "username", password: "password") { (status) in
            guard let expect = expect else {
                XCTFail("Expectation Unavailable")
                return
            }

            XCTAssertEqual(userAuth.status, .loggedOut)

            // Check credentials not present
            let credential = URLCredentialStorage.shared.defaultCredential(for: UserAuth.protectionSpace)
            XCTAssertNil(credential)

            expect.fulfill()
        }

        // Check credentials are present but only temporarily
        let tempCredential = URLCredentialStorage.shared.defaultCredential(for: UserAuth.protectionSpace)
        XCTAssertNotNil(tempCredential)
        XCTAssertEqual(tempCredential!.persistence, .forSession)
        XCTAssertEqual(userAuth.status, .pendingValidation)

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testLogInLogOutCredentialsPermanentIfSuccessful() {
        Environment.backend = TestingBackendService(shouldFailLogin: false)
        let userAuth = UserAuth()

        // Log out if the credentials exist
        if let credential = URLCredentialStorage.shared.defaultCredential(for: UserAuth.protectionSpace) {
            URLCredentialStorage.shared.remove(credential, for: UserAuth.protectionSpace)
        }
        // Ensure that credentials are not present
        XCTAssertNil(URLCredentialStorage.shared.defaultCredential(for: UserAuth.protectionSpace))

        weak var expect = expectation(description: "testLogInLogOutCredentialsPermanentIfSuccessful")
        userAuth.logIn(with: "username", password: "password") { (status) in
            guard let expect = expect else {
                XCTFail("Expectation Unavailable")
                return
            }

            XCTAssertEqual(userAuth.status, .loggedIn)

            // Check credentials present
            let credential = URLCredentialStorage.shared.defaultCredential(for: UserAuth.protectionSpace)
            XCTAssertNotNil(credential)
            XCTAssertEqual(credential!.persistence, .permanent)

            expect.fulfill()
        }

        // Check credentials are present but only temporarily
        let tempCredential = URLCredentialStorage.shared.defaultCredential(for: UserAuth.protectionSpace)
        XCTAssertNotNil(tempCredential)
        XCTAssertEqual(tempCredential!.persistence, .forSession)
        XCTAssertEqual(userAuth.status, .pendingValidation)

        waitForExpectations(timeout: 2, handler: nil)
    }

    private struct TestingBackendService: BackendService {
        private let shouldFailLogin: Bool

        init(shouldFailLogin: Bool) {
            self.shouldFailLogin = shouldFailLogin
        }

        func create<Req, Res>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
            where Req: Request, Res: Decodable {
        }

        func read<Req, Res>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
            where Req: Request, Res: Decodable {
            if shouldFailLogin {
                callback(false, nil)
            } else {
                // swiftlint:disable force_cast
                let response = AuthStatusResponse(status: true, username: "username") as! Res
                // swiftlint:enable force_cast
                callback(true, response)
            }
        }

        func update<Req, Res>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
            where Req: Request, Res: Decodable {
        }

        func delete<Req, Res>(_ request: Req, callback: @escaping (Bool, Res?) -> Void)
            where Req: Request, Res: Decodable {
        }

    }

}

//
//  AccountDetailTests.swift
//  AuraTests
//
//  Created by pascal jesenberger on 27/01/2025.
//

import XCTest
@testable import Aura

class AppViewModelTests: XCTestCase {
    var appViewModel: AppViewModel!
    
    override func setUp() {
        super.setUp()
        appViewModel = AppViewModel()
    }
    
    override func tearDown() {
        appViewModel = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertFalse(appViewModel.isLogged)
    }
    
    func testAuthenticationViewModel() {
        let authViewModel = appViewModel.authenticationViewModel
        authViewModel.onLoginSucceed()
        XCTAssertTrue(appViewModel.isLogged)
    }
    
    func testAccountDetailViewModel() {
        let accountDetailViewModel = appViewModel.accountDetailViewModel
        XCTAssertNotNil(accountDetailViewModel)
    }
}

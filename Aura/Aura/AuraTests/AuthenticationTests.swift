//
//  AuthenticationTests.swift
//  AuraTests
//
//  Created by pascal jesenberger on 27/01/2025.
//

import XCTest
@testable import Aura

class AuthenticationTests: XCTestCase {
    var authViewModel: AuthenticationViewModel!
    
    override func setUp() {
        super.setUp()
        authViewModel = AuthenticationViewModel({})
    }
    
    func testValidEmailFormat() {
        let validEmails = [
            "test@example.com",
            "user.name@domain.co.uk",
            "firstname+lastname@domain.com"
        ]
        
        let invalidEmails = [
            "invalid-email",
            "test@",
            "@domain.com",
            "test@domain"
        ]
        
        validEmails.forEach { email in
            authViewModel.username = email
            authViewModel.validateEmail()
            XCTAssertTrue(authViewModel.isEmailValid, "Email \(email) should be valid")
        }
        
        invalidEmails.forEach { email in
            authViewModel.username = email
            authViewModel.validateEmail()
            XCTAssertFalse(authViewModel.isEmailValid, "Email \(email) should be invalid")
        }
    }
    
    func testAuthenticationFailureHandling() {
        let expectation = XCTestExpectation(description: "Authentication failure")
        
        authViewModel.username = "invalid@email.com"
        authViewModel.password = "wrongpassword"
        
        authViewModel.login()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertNotNil(self.authViewModel.error, "Authentication should fail with invalid credentials")
            XCTAssertFalse(self.authViewModel.isLoading, "Loading state should be reset after failed authentication")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}

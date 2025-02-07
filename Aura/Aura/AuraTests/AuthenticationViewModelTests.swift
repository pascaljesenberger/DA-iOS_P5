//
//  AuthenticationTests.swift
//  AuraTests
//
//  Created by pascal jesenberger on 27/01/2025.
//

import XCTest
@testable import Aura

class AuthenticationViewModelTests: XCTestCase {
    var authViewModel: AuthenticationViewModel!
    
    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(MockURLProtocol.self)
        authViewModel = AuthenticationViewModel({})
    }
    
    override func tearDown() {
        URLProtocol.unregisterClass(MockURLProtocol.self)
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }
    
    func testValidEmailFormats() {
        let validEmails = [
            "test@example.com",
            "user.name@domain.co.uk",
            "firstname+lastname@domain.com"
        ]
        
        validEmails.forEach { email in
            authViewModel.username = email
            authViewModel.validateEmail()
            XCTAssertTrue(authViewModel.isEmailValid, "Email \(email) should be valid")
        }
    }
    
    func testInvalidEmailFormats() {
        let invalidEmails = [
            "invalid-email",
            "test@",
            "@domain.com",
            "test@domain",
            ""
        ]
        
        invalidEmails.forEach { email in
            authViewModel.username = email
            authViewModel.validateEmail()
            XCTAssertFalse(authViewModel.isEmailValid, "Email \(email) should be invalid")
        }
    }
    
    @MainActor func testEmptyCredentials() {
        authViewModel.username = ""
        authViewModel.password = ""
        authViewModel.login()
        
        XCTAssertFalse(authViewModel.isEmailValid)
        XCTAssertFalse(authViewModel.isLoading)
    }
    
    @MainActor func testSuccessfulAuthentication() {
        let expectation = XCTestExpectation(description: "Successful authentication")
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let authResponse = AuthResponse(token: "test-token")
            let data = try! JSONEncoder().encode(authResponse)
            return (response, data)
        }
        
        authViewModel.username = "test@example.com"
        authViewModel.password = "password123"
        authViewModel.login()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNil(self.authViewModel.error)
            XCTAssertFalse(self.authViewModel.isLoading)
            XCTAssertEqual(UserDefaults.standard.string(forKey: "authToken"), "test-token")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    @MainActor func testFailedAuthentication() {
        let expectation = XCTestExpectation(description: "Failed authentication")
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        
        authViewModel.username = "test@example.com"
        authViewModel.password = "wrongpassword"
        authViewModel.login()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNotNil(self.authViewModel.error)
            XCTAssertFalse(self.authViewModel.isLoading)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}

//
//  AccountDetailTests.swift
//  AuraTests
//
//  Created by pascal jesenberger on 27/01/2025.
//

import XCTest
@testable import Aura

class NetworkErrorTests: XCTestCase {
    
    var authViewModel: AuthenticationViewModel!
    var accountViewModel: AccountDetailViewModel!
    var transferViewModel: MoneyTransferViewModel!
    
    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(MockURLProtocol.self)
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        
        authViewModel = AuthenticationViewModel({})
        accountViewModel = AccountDetailViewModel()
        transferViewModel = MoneyTransferViewModel()
    }
    
    override func tearDown() {
        URLProtocol.unregisterClass(MockURLProtocol.self)
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }
    
    @MainActor func testAuthenticationNetworkError() {
        let expectation = XCTestExpectation(description: "Network error in authentication")
        
        MockURLProtocol.requestHandler = { request in
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        }
        
        authViewModel.username = "test@example.com"
        authViewModel.password = "password"
        authViewModel.login()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNotNil(self.authViewModel.error)
            XCTAssertFalse(self.authViewModel.isLoading)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testAccountDetailsNetworkTimeout() {
        let expectation = XCTestExpectation(description: "Network timeout in account details")
        
        MockURLProtocol.requestHandler = { request in
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut)
        }
        
        accountViewModel.fetchAccountDetails()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNotNil(self.accountViewModel.error)
            XCTAssertFalse(self.accountViewModel.isLoading)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    @MainActor func testTransferNetworkServerError() {
        let expectation = XCTestExpectation(description: "Server error in transfer")
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        
        transferViewModel.recipient = "test@example.com"
        transferViewModel.amount = "100"
        transferViewModel.sendMoney()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNotNil(self.transferViewModel.error)
            XCTAssertFalse(self.transferViewModel.isLoading)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
     func testInvalidJSONResponse() {
        let expectation = XCTestExpectation(description: "Invalid JSON response")
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let invalidJSON = "invalid json".data(using: .utf8)!
            return (response, invalidJSON)
        }
        
        accountViewModel.fetchAccountDetails()
        
       DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNotNil(self.accountViewModel.error)
            XCTAssertEqual(self.accountViewModel.error, "Invalid response")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler is unavailable.")
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}

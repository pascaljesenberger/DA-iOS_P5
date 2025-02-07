//
//  AccountDetailTests.swift
//  AuraTests
//
//  Created by pascal jesenberger on 27/01/2025.
//

import XCTest
@testable import Aura

class AccountDetailViewModelTests: XCTestCase {
    var accountViewModel: AccountDetailViewModel!
    
    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(MockURLProtocol.self)
        accountViewModel = AccountDetailViewModel()
    }
    
    override func tearDown() {
        URLProtocol.unregisterClass(MockURLProtocol.self)
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }
    
    func testSuccessfulAccountDetailsFetch() {
        let expectation = XCTestExpectation(description: "Account details fetch")
        
        let mockResponse = AccountDetailAPIResponse(
            currentBalance: 1000.50,
            transactions: [
                AccountDetailAPITransaction(value: 100.0, label: "Deposit"),
                AccountDetailAPITransaction(value: -50.0, label: "Withdrawal")
            ]
        )
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = try! JSONEncoder().encode(mockResponse)
            return (response, data)
        }
        
        UserDefaults.standard.set("test-token", forKey: "authToken")
        accountViewModel.fetchAccountDetails()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNil(self.accountViewModel.error)
            XCTAssertEqual(self.accountViewModel.totalAmount, "€1000.50")
            XCTAssertEqual(self.accountViewModel.recentTransactions.count, 2)
            XCTAssertFalse(self.accountViewModel.isLoading)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testNoTokenError() {
        let expectation = XCTestExpectation(description: "No token error")
        
        UserDefaults.standard.removeObject(forKey: "authToken")
        accountViewModel.fetchAccountDetails()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNotNil(self.accountViewModel.error)
            XCTAssertFalse(self.accountViewModel.isLoading)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}

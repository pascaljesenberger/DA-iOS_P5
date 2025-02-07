//
//  AccountDetailTests.swift
//  AuraTests
//
//  Created by pascal jesenberger on 27/01/2025.
//

import XCTest
@testable import Aura

class AllTransactionsViewModelTests: XCTestCase {
    var allTransactionsViewModel: AllTransactionsViewModel!
    
    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(MockURLProtocol.self)
        allTransactionsViewModel = AllTransactionsViewModel()
    }
    
    override func tearDown() {
        URLProtocol.unregisterClass(MockURLProtocol.self)
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }
    
    func testSuccessfulAllTransactionsFetch() {
        let expectation = XCTestExpectation(description: "All transactions fetch")
        
        let mockResponse = AllTransactionsAPIResponse(
            currentBalance: 1000.50,
            transactions: [
                AllTransactionsAPITransaction(value: 100.0, label: "Deposit"),
                AllTransactionsAPITransaction(value: -50.0, label: "Withdrawal")
            ]
        )
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = try! JSONEncoder().encode(mockResponse)
            return (response, data)
        }
        
        UserDefaults.standard.set("test-token", forKey: "authToken")
        allTransactionsViewModel.fetchTransactions()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNil(self.allTransactionsViewModel.error)
            XCTAssertEqual(self.allTransactionsViewModel.transactions.count, 2)
            XCTAssertFalse(self.allTransactionsViewModel.isLoading)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testTransactionConversion() {
        let apiTransaction = AllTransactionsAPITransaction(value: 100.0, label: "Test Transaction")
        let transaction = AllTransactionsViewModel.Transaction.from(apiTransaction: apiTransaction)
        
        XCTAssertEqual(transaction.description, "Test Transaction")
        XCTAssertEqual(transaction.amount, "+€100.00")
    }
}

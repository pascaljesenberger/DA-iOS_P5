//
//  AccountDetailTests.swift
//  AuraTests
//
//  Created by pascal jesenberger on 27/01/2025.
//

import XCTest
@testable import Aura

class AccountDetailTests: XCTestCase {
    var accountDetailViewModel: AccountDetailViewModel!
    
    override func setUp() {
        super.setUp()
        accountDetailViewModel = AccountDetailViewModel()
    }
    
    func testAccountDetailsFetchFailure() {
        let expectation = XCTestExpectation(description: "Account details fetch failure")
        
        // Supprimer le token pour simuler une erreur d'authentification
        UserDefaults.standard.removeObject(forKey: "authToken")
        
        accountDetailViewModel.fetchAccountDetails()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertNotNil(self.accountDetailViewModel.error, "Account details fetch should fail without authentication")
            XCTAssertFalse(self.accountDetailViewModel.isLoading, "Loading state should be reset after fetch failure")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testTransactionConversion() {
        let mockTransaction = AccountDetailAPITransaction(value: 100.50, label: "Test Transaction")
        let convertedTransaction = AccountDetailViewModel.Transaction.from(apiTransaction: mockTransaction)
        
        XCTAssertEqual(convertedTransaction.description, "Test Transaction")
        XCTAssertEqual(convertedTransaction.amount, "+€100.50")
    }
}

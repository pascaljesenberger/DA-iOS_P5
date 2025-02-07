//
//  MoneyTransferTests.swift
//  AuraTests
//
//  Created by pascal jesenberger on 27/01/2025.
//

import XCTest
@testable import Aura

class MoneyTransferViewModelTests: XCTestCase {
    var transferViewModel: MoneyTransferViewModel!
    
    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(MockURLProtocol.self)
        transferViewModel = MoneyTransferViewModel()
    }
    
    override func tearDown() {
        URLProtocol.unregisterClass(MockURLProtocol.self)
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }
    
    func testValidRecipientFormats() {
        let validRecipients = [
            "test@example.com",
            "+33601020304",
            "+33 6 01 02 03 04"
        ]
        
        validRecipients.forEach { recipient in
            transferViewModel.recipient = recipient
            XCTAssertTrue(transferViewModel.validateRecipient(), "Recipient \(recipient) should be valid")
            XCTAssertTrue(transferViewModel.isRecipientValid)
        }
    }
    
    func testInvalidRecipientFormats() {
        let invalidRecipients = [
            "invalid-email",
            "+44601020304",
            "06 01 02 03 04",
            ""
        ]
        
        invalidRecipients.forEach { recipient in
            transferViewModel.recipient = recipient
            XCTAssertFalse(transferViewModel.validateRecipient(), "Recipient \(recipient) should be invalid")
            XCTAssertFalse(transferViewModel.isRecipientValid)
        }
    }
    
    @MainActor func testInvalidAmount() {
        transferViewModel.recipient = "test@example.com"
        transferViewModel.amount = "-100"
        transferViewModel.sendMoney()
        
        XCTAssertNotNil(transferViewModel.error)
        XCTAssertFalse(transferViewModel.isAmountValid)
    }
    
    @MainActor func testSuccessfulMoneyTransfer() {
        let expectation = XCTestExpectation(description: "Successful money transfer")
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        
        UserDefaults.standard.set("test-token", forKey: "authToken")
        transferViewModel.recipient = "test@example.com"
        transferViewModel.amount = "100.50"
        transferViewModel.sendMoney()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNil(self.transferViewModel.error)
            XCTAssertFalse(self.transferViewModel.isLoading)
            XCTAssertTrue(self.transferViewModel.transferMessage.contains("Successfully transferred"))
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}

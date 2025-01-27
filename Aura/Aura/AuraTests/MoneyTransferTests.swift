//
//  MoneyTransferTests.swift
//  AuraTests
//
//  Created by pascal jesenberger on 27/01/2025.
//

import XCTest
@testable import Aura

class MoneyTransferTests: XCTestCase {
    var moneyTransferViewModel: MoneyTransferViewModel!
    
    override func setUp() {
        super.setUp()
        moneyTransferViewModel = MoneyTransferViewModel()
    }
    
    func testValidRecipientFormats() {
        let validRecipients = [
            "test@example.com",
            "+33601020304",
            "+33 6 01 02 03 04"
        ]
        
        let invalidRecipients = [
            "invalid-email",
            "+44601020304",
            "06 01 02 03 04"
        ]
        
        validRecipients.forEach { recipient in
            moneyTransferViewModel.recipient = recipient
            XCTAssertTrue(moneyTransferViewModel.validateRecipient(), "Recipient \(recipient) should be valid")
        }
        
        invalidRecipients.forEach { recipient in
            moneyTransferViewModel.recipient = recipient
            XCTAssertFalse(moneyTransferViewModel.validateRecipient(), "Recipient \(recipient) should be invalid")
        }
    }
    
    func testInvalidAmountHandling() {
        let invalidAmounts = [
            "-10",
            "0",
            "abc",
            ""
        ]
        
        invalidAmounts.forEach { amount in
            moneyTransferViewModel.amount = amount
            XCTAssertFalse(moneyTransferViewModel.validateAmount(), "Amount \(amount) should be invalid")
        }
    }
}

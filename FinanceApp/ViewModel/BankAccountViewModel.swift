//
//  BankAccountViewModel.swift
//  FinanceApp
//
//  Created by Тася Галкина on 27.06.2025.
//

import SwiftUI

@MainActor
final class BankAccountViewModel: ObservableObject {
    @Published var bankAccountInfo: BankAccount?
    @Published var isEditing: Bool = false
    
    @Published var showInvalidBalanceAlert: Bool = false
    
    private let bankAccountService: BankAccountsServiceProtocol = BankAccountsService()
    
    func loadBankAccountInfo() async {
        do {
            self.bankAccountInfo = try await  bankAccountService.getBankAccount() ?? nil
        } catch {
            print("cant get bank account")
        }
    }
    
    func updateCurrencyInfo( _ newCurrency: String) async {
        
        guard let bankAccountInfo = bankAccountInfo else { return }
        
        guard bankAccountInfo.currency != newCurrency else { return }
        
        let newBankAccount = BankAccount(
            id: bankAccountInfo.id,
            userId: bankAccountInfo.userId,
            name: bankAccountInfo.name,
            balance: bankAccountInfo.balance,
            currency: newCurrency,
            createdAt: bankAccountInfo.createdAt,
            updatedAt: bankAccountInfo.updatedAt
        )
        do {
            try await  bankAccountService.updateBankAccount(newBankAccount)
            try await loadBankAccountInfo()
        } catch {
            print("cant save bank account")
        }
    }
    
    func updateBalanceInfo(_ newBalance: Decimal) async {
        
        guard let bankAccountInfo = bankAccountInfo else { return }
        
        let newBankAccount = BankAccount(
            id: bankAccountInfo.id,
            userId: bankAccountInfo.userId,
            name: bankAccountInfo.name,
            balance: newBalance,
            currency: bankAccountInfo.currency,
            createdAt: bankAccountInfo.createdAt,
            updatedAt: bankAccountInfo.updatedAt
        )
        do {
            try await  bankAccountService.updateBankAccount(newBankAccount)
            try await loadBankAccountInfo()
        } catch {
            print("cant save bank account")
        }
    }
    
    func saveChanges(newBalanceText: String) async {
        let cleanNewBalanceText = newBalanceText.replacingOccurrences(of: ",", with: ".")
        if filterValidBalance(cleanNewBalanceText) {
            if let newBalance = Decimal(string: cleanNewBalanceText) {
                await updateBalanceInfo(newBalance)
                isEditing = false
            } else {
                showInvalidBalanceAlert = true
            }
        } else {
            showInvalidBalanceAlert = true
        }
    }
    
    func filterValidBalance(_ text: String) -> Bool {
        let validCharacters = CharacterSet(charactersIn: "0123456789.,-")
        let filtered = text.components(separatedBy: validCharacters.inverted).joined()
        var result = filtered.replacingOccurrences(of: ",", with: ".")
        
        if result.filter({ $0 == "." }).count > 1 {
            if let firstDotIndex = result.firstIndex(of: ".") {
                result = String(result.prefix(upTo: firstDotIndex)) + String(result.suffix(from: result.index(after: firstDotIndex)).filter { $0 != "." })
            }
        }
        
        if result.filter({ $0 == "-" }).count > 1 || (result.first == "-" && result.dropFirst().contains("-")) {
            result = result.replacingOccurrences(of: "-", with: "")
        }
        
        return result == text
    }
}

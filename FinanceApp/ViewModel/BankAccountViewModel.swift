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
        isEditing = false
        let cleanedText = newBalanceText.replacingOccurrences(of: ",", with: ".")
        if let newBalance = Decimal(string: cleanedText) {
            await updateBalanceInfo(newBalance)
        }
    }
}

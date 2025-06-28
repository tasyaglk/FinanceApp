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
    
    func updateBankAccountInfo(_ newBalance: String, _ newCurrency: String) async {
        
        guard let bankAccountInfo = bankAccountInfo else { return }
        
        guard let balance = Decimal(string: newBalance) else { return }
        
        let newBankAccount = BankAccount(
            id: bankAccountInfo.id,
            userId: bankAccountInfo.userId,
            name: bankAccountInfo.name,
            balance: balance,
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
    
    
    func saveChanges() {
        isEditing = false
    }
}

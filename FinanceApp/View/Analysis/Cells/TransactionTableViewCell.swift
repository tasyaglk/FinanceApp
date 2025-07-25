//
//  TransactionTableViewCell.swift
//  FinanceApp
//
//  Created by Тася Галкина on 11.07.2025.
//

import UIKit

import UIKit

final class TransactionTableViewCell: UITableViewCell {
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let percentageLabel = UILabel()
    private let amountLabel = UILabel()
    private let chevronImageView = UIImageView()
    
    private let titleStack = UIStackView()
    private let amountStack = UIStackView()
    private let mainStack = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCellUI() {
        setupEmojiLabel()
        setupTitleLabel()
        setupDescriptionLabel()
        setupTitleStack()
        setupPercentageLabel()
        setupAmountLabel()
        setupChevronImageView()
        setupAmountStack()
        setupMainStack()
    }
    
    func setupEmojiLabel() {
        emojiLabel.font = .systemFont(ofSize: 20)
        emojiLabel.textAlignment = .center
        emojiLabel.backgroundColor = .lightMain
        emojiLabel.layer.cornerRadius = 16
        emojiLabel.layer.masksToBounds = true
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emojiLabel.widthAnchor.constraint(equalToConstant: 32),
            emojiLabel.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    func setupTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 17)
    }
    
    func setupDescriptionLabel() {
        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = .systemGray
    }
    
    func setupTitleStack() {
        titleStack.axis = .vertical
        titleStack.spacing = 2
        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(descriptionLabel)
    }
    
    func setupPercentageLabel() {
        percentageLabel.font = .systemFont(ofSize: 15, weight: .medium)
        percentageLabel.textAlignment = .right
    }
    
    func setupAmountLabel() {
        amountLabel.font = .systemFont(ofSize: 15, weight: .medium)
        amountLabel.textAlignment = .right
    }
    
    func setupChevronImageView() {
        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.tintColor = .systemGray3
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func setupAmountStack() {
        amountStack.axis = .vertical
        amountStack.spacing = 2
        amountStack.alignment = .trailing
        amountStack.addArrangedSubview(percentageLabel)
        amountStack.addArrangedSubview(amountLabel)
    }
    
    func setupMainStack() {
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        mainStack.addArrangedSubview(emojiLabel)
        mainStack.addArrangedSubview(titleStack)
        mainStack.addArrangedSubview(UIView()) 
        mainStack.addArrangedSubview(amountStack)
        mainStack.addArrangedSubview(chevronImageView)
        
        titleStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        amountStack.setContentHuggingPriority(.required, for: .horizontal)
        amountStack.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with transaction: Transaction, category: Category?, percentage: String) {
        emojiLabel.text = String(category?.emoji ?? "?")
        titleLabel.text = category?.name ?? "undefined"
        descriptionLabel.text = transaction.comment ?? ""
        amountLabel.text = "\(transaction.amount) \(Constants.russianCurrency)"
        percentageLabel.text = percentage
    }
}

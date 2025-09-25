//
//  TotalCell.swift
//  FinanceApp
//
//  Created by Тася Галкина on 11.07.2025.
//

import UIKit

final class TotalCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let totalLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setupTitle()
        setupTotal()
    }
    
    private func setupTitle() {
        contentView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.padding),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    private func setupTotal() {
        contentView.addSubview(totalLabel)
        
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            totalLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.padding),
            totalLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(title: String, total: Decimal) {
        titleLabel.text = title
        totalLabel.text = "\(total)"
    }
}

//
//  DatePickerCell.swift
//  FinanceApp
//
//  Created by Тася Галкина on 11.07.2025.
//

import UIKit

final class DatePickerCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let datePicker = UIDatePicker()
    
    var onDateChanged: ((Date) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setupTitle()
        setupPicker()
    }
    
    private func setupTitle() {
        contentView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.padding),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func setupPicker() {
        contentView.addSubview(datePicker)
        
        datePicker.backgroundColor = UIColor.lightMain
        datePicker.layer.cornerRadius = Constants.cornerRadius
        datePicker.clipsToBounds = true
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.padding),
            datePicker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }
    
    func configure(title: String, date: Date, mode: UIDatePicker.Mode) {
        titleLabel.text = title
        datePicker.datePickerMode = mode
        datePicker.date = date
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        onDateChanged?(sender.date)
    }
}

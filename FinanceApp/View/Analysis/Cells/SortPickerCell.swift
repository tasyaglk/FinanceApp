//
//  SortPickerCell.swift
//  FinanceApp
//
//  Created by Тася Галкина on 11.07.2025.
//

import UIKit

final class SortPickerCell: UITableViewCell {
    private let titleLabel = UILabel()
    private var segmentedControl: UISegmentedControl?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.padding),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(title: String, segmentedControl: UISegmentedControl) {
        titleLabel.text = title
        self.segmentedControl?.removeFromSuperview()
        self.segmentedControl = segmentedControl
        contentView.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.padding),
            segmentedControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            segmentedControl.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: Constants.smallPadding)
        ])
    }
}

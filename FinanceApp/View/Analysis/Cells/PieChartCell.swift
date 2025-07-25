//
//  PieChartCell.swift
//  FinanceApp
//
//  Created by Тася Галкина on 25.07.2025.
//

import UIKit
import PieChart

final class PieChartCell: UITableViewCell {
    private let chartView = PieChartView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupChartView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupChartView() {
        contentView.addSubview(chartView)
        
        chartView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            chartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            chartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chartView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            chartView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    func configure(with entities: [Entity]) {
        chartView.entities = entities
    }
}


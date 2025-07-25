//
//  AnalysisViewController.swift
//  FinanceApp
//
//  Created by Тася Галкина on 11.07.2025.
//

import UIKit
import SwiftUI
import PieChart

class AnalysisViewController: UIViewController {
    private let viewModel: AnalysisViewModel
    
    private let titleLabel = UILabel()
    private let backButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()
    private let sortSegmentedControl = UISegmentedControl(items: SortOption.allCases.map { $0.rawValue })
    private let chartView = PieChartView()
    
    init(direction: Direction, startDate: Date, endDate: Date) {
        self.viewModel = AnalysisViewModel(direction: direction, customDates: true)
        super.init(nibName: nil, bundle: nil)
        self.viewModel.startDate = startDate
        self.viewModel.endDate = endDate
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await viewModel.fetchInfo()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        setupUI()
        setupBindings()
        Task {
            await viewModel.fetchInfo()
        }
    }
    
    private func setupUI() {
        setUpBackButton()
        setupTitle()
        setupTable()
        setupSortSegmentedControl()
    }
    
    private func setUpBackButton() {
        view.addSubview(backButton)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.setTitle("Назад", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        backButton.tintColor = .button
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.smallPadding),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
        ])
    }
    
    private func setupTitle() {
        view.addSubview(titleLabel)
        titleLabel.text = Constants.analysisTitle
        titleLabel.font = .systemFont(ofSize: CGFloat(Constants.titleFontSize), weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: CGFloat(Constants.smallPadding)),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CGFloat(Constants.padding)),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CGFloat(Constants.padding)),
        ])
    }
    
    private func setupTable() {
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: "DateCell")
        tableView.register(SortPickerCell.self, forCellReuseIdentifier: "SortCell")
        tableView.register(TotalCell.self, forCellReuseIdentifier: "TotalCell")
        tableView.register(PieChartCell.self, forCellReuseIdentifier: "PieChartCell")
        tableView.register(TransactionTableViewCell.self, forCellReuseIdentifier: "TransactionCell")
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.smallPadding),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupSortSegmentedControl() {
        sortSegmentedControl.selectedSegmentIndex = SortOption.allCases.firstIndex(of: viewModel.sortOption) ?? 0
        sortSegmentedControl.addTarget(self, action: #selector(sortValueChanged(_:)), for: .valueChanged)
    }
    
    private func setupBindings() {
        viewModel.onDataUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    @objc private func datePickerChanged(_ sender: UIDatePicker) {
        if sender == startDatePicker {
            viewModel.startDate = sender.date
            if viewModel.endDate < sender.date {
                viewModel.endDate = sender.date
                endDatePicker.date = sender.date
            }
        } else if sender == endDatePicker {
            viewModel.endDate = sender.date
            if viewModel.startDate > sender.date {
                viewModel.startDate = sender.date
                startDatePicker.date = sender.date
            }
        }
        Task {
            await viewModel.fetchInfo()
        }
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func sortValueChanged(_ sender: UISegmentedControl) {
        let selectedSortOption = SortOption.allCases[sender.selectedSegmentIndex]
        viewModel.sortOption = selectedSortOption
    }
}

extension AnalysisViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        } else {
            return viewModel.transactions.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath) as! DatePickerCell
                cell.configure(title: Constants.beginTitle, date: viewModel.startDate, mode: .date)
                cell.onDateChanged = { [weak self] date in
                    guard let self = self else { return }
                    self.viewModel.startDate = date
                    if self.viewModel.endDate < date {
                        self.viewModel.endDate = date
                        self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
                    }
                    Task { await self.viewModel.fetchInfo() }
                }
                cell.selectionStyle = .none
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath) as! DatePickerCell
                cell.configure(title: Constants.endTitle, date: viewModel.endDate, mode: .date)
                cell.onDateChanged = { [weak self] date in
                    guard let self = self else { return }
                    self.viewModel.endDate = date
                    if self.viewModel.startDate > date {
                        self.viewModel.startDate = date
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                    }
                    Task { await self.viewModel.fetchInfo() }
                }
                cell.selectionStyle = .none
                return cell
                
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SortCell", for: indexPath) as! SortPickerCell
                cell.configure(title: Constants.sortTitle, segmentedControl: sortSegmentedControl)
                cell.selectionStyle = .none
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TotalCell", for: indexPath) as! TotalCell
                cell.configure(title: Constants.amountTitle, total: viewModel.totalAmount)
                cell.selectionStyle = .none
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PieChartCell", for: indexPath) as! PieChartCell
                cell.configure(with: viewModel.chartEntities)
                cell.selectionStyle = .none
                return cell
            default:
                return UITableViewCell()
            }

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionTableViewCell
            let transaction = viewModel.transactions[indexPath.row]
            cell.configure(with: transaction, category: viewModel.categories[transaction.categoryId], percentage: viewModel.getPercentage(for: transaction))
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 && !viewModel.transactions.isEmpty {
            return Constants.operationTitle
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        
        let transaction = viewModel.transactions[indexPath.row]
        let editView = EditAndAddView(direction: viewModel.direction, transaction: transaction)
        
        let hostingController = UIHostingController(rootView: editView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
}

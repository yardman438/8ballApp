//
//  SettingsScreenViewController.swift
//  8ballApp
//
//  Created by Sergey Dvornik on 08.11.2021.
//
// swiftlint:disable trailing_whitespace

import UIKit
import SnapKit

class SettingsScreenViewController: UIViewController {
    
    private let customAnswerLabel = UILabel()
    private let addAnswerButton = UIButton(type: .system)
    private let tableView = UITableView()
    private let visualEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blurEffect)
        return view
    }()
    
    var settingsScreenViewModel: SettingsScreenViewModel
    
    init(viewModel: SettingsScreenViewModel) {
        self.settingsScreenViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingsScreenViewModel.loadDefaultAnswers()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
        configureTableView()
    }
    
    @objc private func addAnswerButtonPressed() {
        alertAnimateIn()
        presentCustomAnswerEditAlertController(withTitle: L10n.alertTitle,
                                               message: nil,
                                               style: .alert) { [unowned self] answer in
            settingsScreenViewModel.saveAnswer(answer)
            alertAnimateOut()
            tableView.reloadData()
        }
    }
}

// MARK: Extensions

extension SettingsScreenViewController {
    
    // The main function to setup interface
    private func setupInterface() {
        view.backgroundColor = UIColor(asset: Asset.backgroundColor)
        
        setupNavigationBar()
        setupCustomAnswerLabel()
        setupAddAnswerButton()
        setupTableView()
        setupVisualEffectView()
    }
    
    private func setupNavigationBar() {
        guard let navBar = navigationController?.navigationBar else { return }
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
    }
    
    // The function to setup the title on the screen
    private func setupCustomAnswerLabel() {
        customAnswerLabel.text = L10n.screenTitle
        customAnswerLabel.textAlignment = .center
        customAnswerLabel.textColor = UIColor(asset: Asset.secondaryColor)
        customAnswerLabel.font = UIFont.systemFont(ofSize: 36)
        view.addSubview(customAnswerLabel)
        customAnswerLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(30)
            make.height.equalTo(43)
            make.width.equalTo(265)
        }
    }
    
    // The function to setup the button for adding new answers
    private func setupAddAnswerButton() {
        addAnswerButton.setTitle(L10n.addButtonCTA, for: .normal)
        addAnswerButton.setTitleColor(UIColor(asset: Asset.buttonColor), for: .normal)
        addAnswerButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        view.addSubview(addAnswerButton)
        addAnswerButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
            make.top.equalTo(customAnswerLabel.snp.bottom).offset(15)
            make.height.equalTo(34)
            make.width.equalTo(159)
        }
        addAnswerButton.addTarget(self, action: #selector(addAnswerButtonPressed), for: .touchUpInside)
    }
    
    // The function to setup the position of the TableView
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(addAnswerButton.snp.bottom).offset(15)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing).inset(32)
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).inset(16)
        }
    }
    
    private func setupVisualEffectView() {
        view.addSubview(visualEffectView)
        visualEffectView.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalTo(view)
        }
        visualEffectView.alpha = 0
    }
}

extension SettingsScreenViewController {
    
    // The function to setup the TableView and a TableViewCell
    private func configureTableView() {
        tableView.register(SettingsScreenTableViewCell.self,
                           forCellReuseIdentifier: SettingsScreenTableViewCell.identifier)
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 50
    }
}

extension SettingsScreenViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsScreenViewModel.defaultAnswers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SettingsScreenTableViewCell.identifier,
                for: indexPath) as? SettingsScreenTableViewCell else { return UITableViewCell() }
        let customAnswer = settingsScreenViewModel.defaultAnswers[indexPath.row].uppercased()
        cell.configureLabel(text: customAnswer)
        return cell
    }
}

extension SettingsScreenViewController {
    
    private func alertAnimateIn() {
        UIView.animate(withDuration: 0.4) {
            self.visualEffectView.alpha = 1
        }
    }
    
    func alertAnimateOut() {
        UIView.animate(withDuration: 0.2) {
            self.visualEffectView.alpha = 0
        }
    }
}

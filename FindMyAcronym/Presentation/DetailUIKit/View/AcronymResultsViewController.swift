//
//  AcronymResultsViewController.swift
//  FindMyAcronym
//
//  Created by Pedro on 16-07-24.
//

import UIKit

class AcronymResultsViewController: UIViewController, AcronymResultsViewProtocol {
    let query: String
    let tableView = UITableView()
    let activityIndicator = UIActivityIndicatorView()
    let errorButton = UIButton()
    let noResultsLabel = UILabel()
    var presenter: AcronymResultsPresenterProtocol?
    private var results: [LongForm]?
    private let cellId = "cell"
    
    init(query: String) {
        self.query = query
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view = UIView()
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(AcronymResultTableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        
        view.addSubview(errorButton)
        errorButton.translatesAutoresizingMaskIntoConstraints = false
        errorButton.setTitle("Reintentar 😔", for: .normal)
        errorButton.isHidden = true
        errorButton.addTarget(self, action: #selector(retry), for: .touchUpInside)
        NSLayoutConstraint.activate([
            errorButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        view.addSubview(noResultsLabel)
        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        noResultsLabel.text = "Sin resultados 🙃"
        noResultsLabel.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.getResults(for: query)
    }
    
    func show(results: [LongForm]) {
        self.results = results
        tableView.reloadData()
    }
    
    func showProgressIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideProgressIndicator() {
        activityIndicator.isHidden = true
    }
    
    func showError() {
        errorButton.isHidden = false
    }
    
    func hideError() {
        errorButton.isHidden = true
    }
    
    //Sample, due to static query will never be displayed
    func showNoResults() {
        noResultsLabel.isHidden = false
    }
    
    @objc
    private func retry() {
        presenter?.getResults(for: query)
    }
}

extension AcronymResultsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) 
                as? AcronymResultTableViewCell, let longForm = results?[indexPath.row] else {
            return UITableViewCell()
        }
        cell.titleLabel.text = longForm.representativeForm
        cell.subtitleLabel.text = "Ocurrencias: \(longForm.occurrences) Desde: \(longForm.since)"
        return cell
    }
}

class AcronymResultTableViewCell: UITableViewCell {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    let subtitleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel
        ])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

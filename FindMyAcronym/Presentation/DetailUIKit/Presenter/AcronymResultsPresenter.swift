//
//  AcronymResultsPresenter.swift
//  FindMyAcronym
//
//  Created by Pedro on 16-07-24.
//

import Foundation

class AcronymResultsPresenter: AcronymResultsPresenterProtocol {
    weak var viewController: AcronymResultsViewProtocol?
    var interactor: AcronymResultsInteractorProtocol?
    
    func getResults(for query: String) {
        interactor?.getResults(for: query)
    }
    
    func present(results: [LongForm]) {
        viewController?.show(results: results)
    }
    
    func showProgressIndicator() {
        viewController?.showProgressIndicator()
    }
    
    func hideProgressIndicator() {
        viewController?.hideProgressIndicator()
    }
    
    func showError() {
        viewController?.showError()
    }
    
    func hideError() {
        viewController?.hideError()
    }
    
    func showNoResults() {
        viewController?.showNoResults()
    }
}

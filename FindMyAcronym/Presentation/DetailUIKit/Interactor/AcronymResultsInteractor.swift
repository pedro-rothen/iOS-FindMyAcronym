//
//  AcronymResultsInteractor.swift
//  FindMyAcronym
//
//  Created by Pedro on 16-07-24.
//

import Foundation
import Combine

class AcronymResultsInteractor: AcronymResultsInteractorProtocol {
    let getLongFormsUseCase: GetLongFormsUseCase
    let presenter: AcronymResultsPresenterProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(getLongFormsUseCase: GetLongFormsUseCase, presenter: AcronymResultsPresenterProtocol) {
        self.getLongFormsUseCase = getLongFormsUseCase
        self.presenter = presenter
    }
    
    func getResults(for query: String) {
        presenter.hideError()
        presenter.showProgressIndicator()
        return getLongFormsUseCase
            .execute(for: query)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.presenter.hideProgressIndicator()
                case .failure(let error):
                    self?.presenter.hideProgressIndicator()
                    if let error = error as? AcronymError, error == .empty {
                        self?.presenter.showNoResults()
                    } else {
                        self?.presenter.showError()
                    }
                }
            }) { [weak self] results in
                self?.presenter.present(results: results)
            }.store(in: &cancellables)
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}

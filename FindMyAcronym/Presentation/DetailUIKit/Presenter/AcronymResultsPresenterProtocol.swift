//
//  AcronymResultsPresenterProtocol.swift
//  FindMyAcronym
//
//  Created by Pedro on 16-07-24.
//

import Foundation

protocol AcronymResultsPresenterProtocol {
    func getResults(for query: String)
    func present(results: [LongForm])
    func showProgressIndicator()
    func hideProgressIndicator()
    func showError()
    func hideError()
    func showNoResults()
}

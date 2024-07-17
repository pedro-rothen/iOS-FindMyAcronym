//
//  AcronymResultsViewProtocol.swift
//  FindMyAcronym
//
//  Created by Pedro on 16-07-24.
//

import Foundation

protocol AcronymResultsViewProtocol: AnyObject {
    func show(results: [LongForm])
    func showProgressIndicator()
    func hideProgressIndicator()
    func showError()
    func hideError()
    func showNoResults()
}

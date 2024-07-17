//
//  AcronymResultsInteractorProtocol.swift
//  FindMyAcronym
//
//  Created by Pedro on 16-07-24.
//

import Foundation
import Combine

protocol AcronymResultsInteractorProtocol {
    func getResults(for query: String)
}

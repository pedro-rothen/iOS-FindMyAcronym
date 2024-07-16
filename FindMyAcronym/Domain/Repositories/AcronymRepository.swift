//
//  AcronymRepository.swift
//  FindMyAcronym
//
//  Created by Pedro on 15-07-24.
//

import Foundation
import Combine

protocol AcronymRepository {
    func getFullforms(forAcronym query: String) -> AnyPublisher<[LongForm], Error>
}

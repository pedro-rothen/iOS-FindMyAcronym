//
//  AcronymRemoteDataSource.swift
//  FindMyAcronym
//
//  Created by Pedro on 15-07-24.
//

import Foundation
import Combine

protocol AcronymRemoteDataSource {
    func getFullforms(forAcronym query: String) -> AnyPublisher<[DictionaryResponse], Error>
}

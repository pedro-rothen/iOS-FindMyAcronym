//
//  AcronymRepositoryImpl.swift
//  FindMyAcronym
//
//  Created by Pedro on 15-07-24.
//

import Foundation
import Combine

class AcronymRepositoryImpl: AcronymRepository {
    let acronymDataSource: AcronymRemoteDataSource
    
    init(acronymDataSource: AcronymRemoteDataSource) {
        self.acronymDataSource = acronymDataSource
    }
    
    func getFullforms(forAcronym query: String) -> AnyPublisher<[LongForm], any Error> {
        return acronymDataSource
            .getFullforms(forAcronym: query)
            .tryMap {
                guard let results = $0.first else { throw AcronymError.empty }
                return results.lfs.map { LongFormMapper.map($0) }
            }.eraseToAnyPublisher()
    }
}

enum AcronymError: Error {
    case empty
}

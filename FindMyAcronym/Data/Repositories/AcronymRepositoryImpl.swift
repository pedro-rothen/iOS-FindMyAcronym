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
            .compactMap {
                $0.first?.lfs.map { LongFormMapper.map($0) }
            }.replaceEmpty(with: [LongForm]())
            .eraseToAnyPublisher()
    }
}

enum AcronymError: Error {
    case empty
}

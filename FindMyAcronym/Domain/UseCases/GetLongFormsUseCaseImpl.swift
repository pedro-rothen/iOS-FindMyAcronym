//
//  GetLongFormsUseCase.swift
//  FindMyAcronym
//
//  Created by Pedro on 15-07-24.
//

import Foundation
import Combine

class GetLongFormsUseCaseImpl: GetLongFormsUseCase {
    let acronymRepository: AcronymRepository
    
    init(acronymRepository: AcronymRepository) {
        self.acronymRepository = acronymRepository
    }
    
    func execute(for query: String) -> AnyPublisher<[LongForm], any Error> {
        return acronymRepository.getFullforms(forAcronym: query)
    }
}

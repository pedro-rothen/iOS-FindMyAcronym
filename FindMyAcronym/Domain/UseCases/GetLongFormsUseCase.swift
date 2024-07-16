//
//  GetLongFormsUseCase.swift
//  FindMyAcronym
//
//  Created by Pedro on 15-07-24.
//

import Foundation
import Combine

protocol GetLongFormsUseCase {
    func execute(for query: String) -> AnyPublisher<[LongForm], Error>
}

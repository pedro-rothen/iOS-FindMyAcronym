//
//  LongFormMapper.swift
//  FindMyAcronym
//
//  Created by Pedro on 15-07-24.
//

import Foundation

struct LongFormMapper {
    static func map(_ response: LongFormApi) -> LongForm {
        return LongForm(representativeForm: response.lf, occurrences: response.freq, since: response.since)
    }
}

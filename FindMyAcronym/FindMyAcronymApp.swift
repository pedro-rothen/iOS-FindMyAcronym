//
//  FindMyAcronymApp.swift
//  FindMyAcronym
//
//  Created by Pedro on 15-07-24.
//

import SwiftUI

@main
struct FindMyAcronymApp: App {
    let getLongFormsUseCase = GetLongFormsUseCaseImpl(acronymRepository: AcronymRepositoryImpl(acronymDataSource: AcronymRemoteDataSourceImpl(service: ApiServiceImpl())))
    
    var body: some Scene {
        WindowGroup {
            SearchAcronymView(viewModel: SearchAcronymViewModel(getLongFormsUseCase: getLongFormsUseCase))
        }
    }
}

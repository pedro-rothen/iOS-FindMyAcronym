//
//  SearchAcronymView.swift
//  FindMyAcronym
//
//  Created by Pedro on 15-07-24.
//

import SwiftUI
import Combine

@MainActor
struct SearchAcronymView: View {
    @State var viewModel: SearchAcronymViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(viewModel.query)
                Content()
            }.navigationTitle("Busca tu acrónimo")
        }.searchable(text: $viewModel.query)
    }
    
    @ViewBuilder
    func Content() -> some View {
        switch viewModel.uiState {
        case .idle:
            EmptyView()
        case .loading:
            ProgressView()
                .controlSize(.large)
        case .error:
            Button(action: {
                //TODO
            }) {
                Text("Reintentar 😔")
            }
        case .success(let results):
            List {
                ForEach(results, id: \.self) { longForm in
                    Text(longForm.representativeForm)
                }
            }
        }
    }
}

@Observable
class SearchAcronymViewModel {
    @ObservationIgnored @Published var query: String = ""
    var uiState: SearchAcronymUiState = .idle
    let getLongFormsUseCase: GetLongFormsUseCase
    private var cancellables = Set<AnyCancellable>()
    
    init(getLongFormsUseCase: GetLongFormsUseCase) {
        self.getLongFormsUseCase = getLongFormsUseCase
        setupSearchObserver()
    }
    
    private func setupSearchObserver() {
        print(#function)
        $query
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] in
            self?.search(query: $0)
        }.store(in: &cancellables)
    }
    
    private func search(query: String) {
        print(#function)
        print("Query: \(query)")
        uiState = .loading
        getLongFormsUseCase
            .execute(for: query)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                    self?.uiState = .error
                }
            }) { [weak self] results in
                print(results)
                self?.uiState = .success(results: results)
            }.store(in: &cancellables)
            
    }
}

enum SearchAcronymUiState {
    case idle, loading, error, success(results: [LongForm])
}

#Preview {
    let getLongFormsUseCase = GetLongFormsUseCaseImpl(acronymRepository: AcronymRepositoryImpl(acronymDataSource: AcronymRemoteDataSourceImpl(service: ApiServiceImpl())))
    
    return SearchAcronymView(viewModel: SearchAcronymViewModel(getLongFormsUseCase: getLongFormsUseCase))
}

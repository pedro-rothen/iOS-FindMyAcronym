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
    @StateObject var viewModel: SearchAcronymViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Content()
            }.navigationTitle("Busca tu acrónimo")
        }.searchable(text: $viewModel.query)
    }
    
    @ViewBuilder
    func Content() -> some View {
        switch viewModel.uiState {
        case .idle:
            EmptyView()
        case .noResults:
            Text("Sin resultados 🙃")
        case .loading:
            ProgressView()
                .controlSize(.large)
        case .error:
            Button(action: {
                viewModel.retry()
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

class SearchAcronymViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var uiState: SearchAcronymUiState = .idle
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
            .sink { [weak self] query in
                if query.count <= 1 {
                    self?.uiState = .idle
                } else {
                    self?.search(query: query)
                }
            }.store(in: &cancellables)
    }
    
    func search(query: String) {
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
                    self?.uiState = {
                        if let acronymError = error as? AcronymError, acronymError == .empty {
                            .noResults
                        } else {
                            .error
                        }
                    }()
                }
            }) { [weak self] results in
                print(results)
                self?.uiState = .success(results: results)
            }.store(in: &cancellables)
            
    }
    
    func retry() {
        search(query: query)
    }
}

enum SearchAcronymUiState {
    case idle, loading, noResults, error, success(results: [LongForm])
}

#Preview {
    let getLongFormsUseCase = GetLongFormsUseCaseImpl(acronymRepository: AcronymRepositoryImpl(acronymDataSource: AcronymRemoteDataSourceImpl(service: ApiServiceImpl())))
    
    let viewModel = SearchAcronymViewModel(getLongFormsUseCase: getLongFormsUseCase)
    return SearchAcronymView(viewModel: viewModel)
}

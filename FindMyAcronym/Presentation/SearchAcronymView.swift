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
            VStack {
                NavigationLink(destination: {
                    let query = viewModel.query
                    AcronymResultsView(query: query)
                        .navigationTitle(query)
                }) {
                    Text("Go to results in UIKit")
                }
                List {
                    ForEach(results, id: \.self) { longForm in
                        VStack(alignment: .leading) {
                            Text(longForm.representativeForm)
                                .fontWeight(.medium)
                            HStack {
                                Text("Ocurrencias: \(longForm.occurrences)")
                                Text("Desde: \(longForm.since)")
                            }
                        }
                    }
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

struct AcronymResultsView: UIViewControllerRepresentable {
    let query: String
    
    func makeUIViewController(context: Context) -> AcronymResultsViewController {
        let presenter = AcronymResultsPresenter()
        let viewController = AcronymResultsViewController(query: query)
        presenter.viewController = viewController
        viewController.presenter = presenter
        let getLongFormsUseCase = GetLongFormsUseCaseImpl(acronymRepository: AcronymRepositoryImpl(acronymDataSource: AcronymRemoteDataSourceImpl(service: ApiServiceImpl())))
        let interactor = AcronymResultsInteractor(getLongFormsUseCase: getLongFormsUseCase, presenter: presenter)
        presenter.interactor = interactor
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: AcronymResultsViewController, context: Context) { }
}

#Preview {
    let getLongFormsUseCase = GetLongFormsUseCaseImpl(acronymRepository: AcronymRepositoryImpl(acronymDataSource: AcronymRemoteDataSourceImpl(service: ApiServiceImpl())))
    
    let viewModel = SearchAcronymViewModel(getLongFormsUseCase: getLongFormsUseCase)
    viewModel.query = "DNA"
    return SearchAcronymView(viewModel: viewModel)
}

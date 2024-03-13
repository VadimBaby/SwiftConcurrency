//
//  SearchableBootcamp.swift
//  ConcurrencySwift
//
//  Created by Вадим Мартыненко on 08.10.2023.
//

import SwiftUI
import Combine

struct Restaurant: Identifiable, Hashable {
    let id: String
    let title: String
    let cuisine: CuisineOption
}

enum CuisineOption: String {
    case american, italian, japanese, russian
}

final class RestaurantManager {
    func getAllRestaurants() async throws -> [Restaurant] {
        return [
            Restaurant(id: "1", title: "Big Tonka", cuisine: .russian),
            Restaurant(id: "2", title: "Burget Shack", cuisine: .american),
            Restaurant(id: "3", title: "Pasta Palace", cuisine: .italian),
            Restaurant(id: "4", title: "Sushi Heaven", cuisine: .japanese)
        ]
    }
}

@MainActor
final class SearchableBootcampViewModel: ObservableObject {
    
    @Published private(set) var allRestaurants: [Restaurant] = []
    @Published private(set) var filteredRestaurants: [Restaurant] = []
    @Published var searchText: String = ""
    @Published var searchScope: SearchScopeOption = .all
    @Published private(set) var allSearchScopes: [SearchScopeOption] = []
    
    var isSearching: Bool {
        return !searchText.isEmpty
    }
    
    var showSearchSuggestion: Bool {
        searchText.count < 3
    }
    
    private let manager = RestaurantManager()
    
    private var cancellables = Set<AnyCancellable>()
    
    enum SearchScopeOption: Hashable {
        case all
        case cuisine(option: CuisineOption)
        
        var title: String {
            switch self {
            case .all:
                return "All"
            case .cuisine(option: let option):
                return option.rawValue.capitalized
            }
        }
    }
    
    init() {
        addSubcribers()
    }
    
    private func addSubcribers() {
        $searchText
            .combineLatest($searchScope)
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] (searchText, searchScope) in
                self?.filterRestaurants(searchText: searchText, currentSearchScope: searchScope)
            }
            .store(in: &cancellables)
    }
    
    private func filterRestaurants(searchText: String, currentSearchScope: SearchScopeOption) {
        guard !searchText.isEmpty else {
            filteredRestaurants = []
            searchScope = .all
            return
        }
        
        var restautantsInScope = allRestaurants
        switch currentSearchScope {
        case .all:
            break
        case .cuisine(let option):
            restautantsInScope = allRestaurants.filter{ $0.cuisine == option }
        }
        
        let search = searchText.lowercased()
        
        filteredRestaurants = restautantsInScope.filter({ restaurant in
            let titleContainsSearch = restaurant.title.lowercased().contains(search)
            let cuisineContaintsSearch = restaurant.cuisine.rawValue.lowercased().contains(search)
            return titleContainsSearch || cuisineContaintsSearch
        })
    }
    
    func loadRestaurants() async {
        do {
            allRestaurants = try await manager.getAllRestaurants()
            
            // we use set because set only unique values
            let allCuisines = Set(allRestaurants.map{ $0.cuisine })
            allSearchScopes = [.all] + allCuisines.map({ option in
                SearchScopeOption.cuisine(option: option)
            })
        } catch {
            print(error)
        }
    }
    
    func getSearchSuggestions() -> [String] {
        guard showSearchSuggestion else { return [] }
        
        var suggestions: [String] = []
        
        let search = searchText.lowercased()
        
        if search.contains("pa") {
            suggestions.append("Pasta")
        }
        
        if search.contains("su") {
            suggestions.append("Sushi")
        }
        
        if search.contains("bu") {
            suggestions.append("Burger")
        }
        
        suggestions.append("Market")
        suggestions.append("Grocery")
        
        suggestions.append(CuisineOption.italian.rawValue.capitalized)
        suggestions.append(CuisineOption.japanese.rawValue.capitalized)
        suggestions.append(CuisineOption.american.rawValue.capitalized)
        
        return suggestions
    }
    
    func getRestaurantSuggestion() -> [Restaurant] {
        guard showSearchSuggestion else { return [] }
        
        var suggestions: [Restaurant] = []
        
        let search = searchText.lowercased()
        
        if search.contains("it") {
            suggestions.append(contentsOf: allRestaurants.filter{ $0.cuisine == .italian })
        }
        
        if search.contains("ja") {
            suggestions.append(contentsOf: allRestaurants.filter{ $0.cuisine == .japanese })
        }
        
        return suggestions
    }
}

struct SearchableBootcamp: View {
    
    @StateObject private var viewModel = SearchableBootcampViewModel()
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(alignment: .leading, spacing: 20){
                    ForEach(viewModel.isSearching ? viewModel.filteredRestaurants : viewModel.allRestaurants) { restaurant in
                        NavigationLink(value: restaurant) {
                            restaurantRow(restaurant: restaurant)
                        }
                    }
                }
                .padding()
            }
            .searchable(text: $viewModel.searchText, placement: .automatic, prompt: Text("Search Restaurants..."))
            .searchScopes($viewModel.searchScope, scopes: {
                ForEach(viewModel.allSearchScopes, id: \.self) { scope in
                    Text(scope.title)
                        .tag(scope)
                }
            })
            .searchSuggestions({
                ForEach(viewModel.getRestaurantSuggestion()) { suggestion in
                    NavigationLink(value: suggestion) {
                        Text(suggestion.title)
                    }
                }
                ForEach(viewModel.getSearchSuggestions(), id: \.self) {
                    Text($0)
                        .searchCompletion($0)
                }
            })
            .navigationTitle("Restaurants")
            .task {
                await viewModel.loadRestaurants()
            }
            .navigationDestination(for: Restaurant.self) { restaurant in
                Text(restaurant.title.uppercased())
            }
        }
    }
}

extension SearchableBootcamp {
    private func restaurantRow(restaurant: Restaurant) -> some View {
        VStack(alignment: .leading, spacing: 10){
            Text(restaurant.title)
                .font(.headline)
                .foregroundStyle(Color.red)
            Text(restaurant.cuisine.rawValue.capitalized)
                .font(.caption)
                .foregroundStyle(Color.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.05))
        .clipShape(.rect(cornerRadius: 10))
    }
}

#Preview {
    SearchableBootcamp()
}

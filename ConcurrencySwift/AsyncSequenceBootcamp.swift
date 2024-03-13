//
//  AsyncSequenceBootcamp.swift
//  ConcurrencySwift
//
//  Created by Вадим Мартыненко on 07.10.2023.
//

import SwiftUI

struct DataSequence: AsyncSequence {
    typealias Element = String
    
    let words: [String]
    
    init(words: [String]) {
        self.words = words
    }
    
    func makeAsyncIterator() -> DataIterator {
        return DataIterator(words: words)
    }
}

struct DataIterator: AsyncIteratorProtocol {
    typealias Element = String
    
    let words: [String]
    
    var index: Int = 0
    
    init(words: [String]) {
        self.words = words
    }
    
    mutating func next() async throws -> String? {
        guard index < words.count else { return nil}
        
        let word = words[index]
        
        self.index += 1
        
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        return word
    }
}

class AsyncSequenceBootcampViewModel: ObservableObject {
    @MainActor @Published var list: [String] = []
    
    func getData(words: [String]) async throws {
        for try await item in DataSequence(words: words) {
            await MainActor.run {
                self.list.append(item)
            }
        }
    }
}

struct AsyncSequenceBootcamp: View {
    
    @StateObject private var viewModel = AsyncSequenceBootcampViewModel()
    
    var body: some View {
        ScrollView{
            VStack{
                ForEach(viewModel.list, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            do{
                let words = ["Apple", "Banana", "Orange", "Damn"]
                try await viewModel.getData(words: words)
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    AsyncSequenceBootcamp()
}

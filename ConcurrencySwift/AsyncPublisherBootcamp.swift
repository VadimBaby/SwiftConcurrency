//
//  AsyncPublisherBootcamp.swift
//  ConcurrencySwift
//
//  Created by Вадим Мартыненко on 07.10.2023.
//

import SwiftUI
import Combine

class AsyncPublisherDataManager {
    @Published var myData: [String] = []
    
    func addData() async {
        myData.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Watermelon")
    }
}

class AsyncPublisherBootcampViewModel: ObservableObject {
    
    @MainActor @Published var dataArray: [String] = []
    
    var cancellables = Set<AnyCancellable>()
    
    let manager = AsyncPublisherDataManager()
    
    init() {
        getSubcribers()
    }
    
    private func getSubcribers() {
    
        Task {
            // цикл никогда сам не остановится
            
            for await value in manager.$myData.values {
                await MainActor.run {
                    self.dataArray = value
                }
            }
        }
        
        // если мы хотим отслеживать еще одну переменную или выполнить другой код, то его нужно писать в новом Task{ }
        
        // например
        
//        Task {
//            
//            // здесь может быть любая переменная вместо manager.$myData или вообще другой код
//            for await value in manager.$myData.values {
//                await MainActor.run {
//                    self.dataArray = value
//                }
//            }
//        }
        
//        manager.$myData
//            .receive(on: DispatchQueue.main)
//            .sink { dataArray in
//                self.dataArray = dataArray
//            }
//            .store(in: &cancellables)
    }
    
    func start() async {
        await manager.addData()
    }
}

struct AsyncPublisherBootcamp: View {
    
    @StateObject private var viewModel = AsyncPublisherBootcampViewModel()
    
    var body: some View {
        ScrollView{
            VStack{
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.start()
        }
    }
}

#Preview {
    AsyncPublisherBootcamp()
}

//
//  StrongSelfBootcamp.swift
//  ConcurrencySwift
//
//  Created by Вадим Мартыненко on 08.10.2023.
//

import SwiftUI

final class StrongSelfDataManager {
    
    func getData() async -> String {
        return "NEW DATA"
    }
}

final class StrongSelfBootcampViewModel: ObservableObject {
    @MainActor @Published var data: String = "Some title"
    
    @MainActor @Published var listData: [String] = []
    
    private var someTask: Task<Void, Never>? = nil
    
    private var listTasks: [Task<Void, Never>] = []
    
    private var subsriber: Task<Void, Never>? = nil
    
    init() {
        getSubcribers()
    }
    
    func cancelTasks() {
        someTask?.cancel()
        someTask = nil
    }
    
    func cancelAllTasks() {
        listTasks.forEach { $0.cancel() }
        listTasks = []
    }
    
    func cancelSubscriber() {
        subsriber?.cancel()
        subsriber = nil
    }
    
    let manager = StrongSelfDataManager()
    
    let publishedManager = AsyncPublisherDataManager()
    
    // we should cancel our tasks to dont get some problems with optimization
    func updateData() {
        someTask = Task {
            let data = await manager.getData()
            
            await MainActor.run {
                self.data = data
            }
        }
    }
    
    func updateData2() {
        let task1 = Task {
            let data = await manager.getData()
            
            await MainActor.run {
                self.data = data
            }
        }
        
        listTasks.append(task1)
        
        let task2 = Task {
            let data = await manager.getData()
            
            await MainActor.run {
                self.data = data
            }
        }
        
        listTasks.append(task2)
    }
    
    // we dont need to cancel this func because .task do this automatically
    func updateData3() async {
        let data = await manager.getData()
        
        await MainActor.run {
            self.data = data
        }
    }
    
    // we dont need to cancel this func because .task do this automatically
    func updateListData() async {
        await publishedManager.addData()
    }
    
    // we can cancel our subcriber
    private func getSubcribers() {
        subsriber = Task {
            for await value in publishedManager.$myData.values {
                await MainActor.run {
                    self.listData = value
                }
            }
        }
    }
}

struct StrongSelfBootcamp: View {
    
    @StateObject private var viewModel = StrongSelfBootcampViewModel()
    
    var body: some View {
        VStack{
            Text(viewModel.data)
                .font(.headline)
            
            ForEach(viewModel.listData, id: \.self, content: {
                Text($0)
                    .font(.headline)
            })
        }
        .onAppear{
            viewModel.updateData()
            
            viewModel.updateData2()
        }
        .onDisappear(perform: {
            viewModel.cancelTasks()
            
            viewModel.cancelAllTasks()
            
            viewModel.cancelSubscriber()
        })
        .task {
            // we dont need to cancel this func because .task do this automatically
            await viewModel.updateData3()
            
            await viewModel.updateListData()
        }
    }
}

#Preview {
    StrongSelfBootcamp()
}

//
//  AsyncAwait.swift
//  ConcurrencySwift
//
//  Created by Вадим Мартыненко on 16.09.2023.
//

import SwiftUI

class AsyncAwaitViewModel: ObservableObject {
    @Published var listData: [String] = []
    
    func addAuthor1() async {
        let author1 = "Author1 / \(Thread.current)"
        await MainActor.run(body: {
            self.listData.append(author1)
        })
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let author2 = "Author2 / \(Thread.current)"
        
        await MainActor.run(body: {
            self.listData.append(author2)
            
            let author3 = "Author3 / \(Thread.current)"
            self.listData.append(author3)
        })
        
        await addSmth()
    }
    
    func addSmth() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let smth1 = "Smth1 / \(Thread.current)"
        
        await MainActor.run(body: {
            self.listData.append(smth1)
            
            let smth2 = "Smth2 / \(Thread.current)"
            self.listData.append(smth1)
        })
    }
}

struct AsyncAwait: View {
    
    @StateObject private var viewModel = AsyncAwaitViewModel()
    
    var body: some View {
        List(viewModel.listData, id: \.self) { value in
            Text(value)
        }
        .onAppear{
            Task{
                await viewModel.addAuthor1()
            }
        }
    }
}

struct AsyncAwait_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwait()
    }
}

//
//  MVVMBootcamp.swift
//  ConcurrencySwift
//
//  Created by Вадим Мартыненко on 08.10.2023.
//

import SwiftUI

final class MyManagerClass {
    func getData() async throws -> String {
        return "Some Data"
    }
}

actor MyManagerActor {
    func getData() async throws -> String {
        return "Some Data"
    }
}

@MainActor
final class MVVMBootcampViewModel: ObservableObject {
    
    @Published private(set) var myData: String = "Starting text"
    
    private let managerClass = MyManagerClass()
    private let managerActor = MyManagerActor()
    
    private var tasks: [Task<Void, Never>] = []
    
    func cancelAllTasks() {
        tasks.forEach({ $0.cancel() })
        tasks = []
    }
    
    func onCallToActionButtonPressed() {
        let task = Task {
            do{
                self.myData = try await managerActor.getData()
            } catch {
                print(error)
            }
        }
        
        tasks.append(task)
    }
}

struct MVVMBootcamp: View {
    
    @StateObject private var viewModel = MVVMBootcampViewModel()
    
    var body: some View {
        VStack{
            Button(viewModel.myData) {
                viewModel.onCallToActionButtonPressed()
            }
        }
        .onDisappear{
            viewModel.cancelAllTasks()
        }
    }
}

#Preview {
    MVVMBootcamp()
}

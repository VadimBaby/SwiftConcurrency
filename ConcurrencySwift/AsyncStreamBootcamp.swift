//
//  AsyncStreamBootcamp.swift
//  ConcurrencySwift
//
//  Created by Вадим Мартыненко on 12.12.2023.
//

import SwiftUI

class AsyncStreamManager {
    
    static let instance = AsyncStreamManager()
    
    func getAsyncStream() -> AsyncStream<Int> {
        AsyncStream(Int.self) { [weak self] continuation in
            self?.getFakeData(completion: { value in
                continuation.yield(value)
            }, onFinish: {
                continuation.finish()
            })
        }
    }
    
    func getFakeData(
        completion: @escaping (_ value: Int) -> Void,
        onFinish: @escaping () -> Void
    ) {
        let lastNumber = 10
        
        for item in 0...lastNumber {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(item), execute: {
                completion(item)
                
                if item == lastNumber {
                    onFinish()
                }
            })
        }
    }
    
    func getAsyncThrowingStream() -> AsyncThrowingStream<Int, Error> {
        AsyncThrowingStream(Int.self) { [weak self] continuation in
            self?.getErrorFakeData(completion: { value in
                continuation.yield(value)
            }, onFinish: { error in
                continuation.finish(throwing: error)
            })
        }
    }
    
    func getErrorFakeData(
        completion: @escaping (_ value: Int) -> Void,
        onFinish: @escaping (_ error: Error?) -> Void
    ) {
        let lastNumber = 10
        
        for item in 0...lastNumber {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(item), execute: {
                completion(item)
                
                if item == lastNumber {
                    onFinish(nil)
                }
            })
        }
    }
}

@MainActor
final class AsyncStreamViewModel: ObservableObject {
    @Published private(set) var currentNumber: Int = 0
    
    private let manager = AsyncStreamManager.instance
    
    func onViewAppear() {
        
        Task {
            do {
                
                // we can use combine methods for AsyncStream and AsyncThrowingStream like .dropFirst and smth
                
//                for try await value in manager.getAsyncThrowingStream().dropFirst() {
//                    currentNumber = value
//                }
                
                for try await value in manager.getAsyncThrowingStream() {
                    currentNumber = value
                }
            } catch {
                print(error)
            }
        }
        
//        Task {
//            for await value in manager.getAsyncStream() {
//                currentNumber = value
//            }
//        }
        
//        manager.getFakeData { [weak self] value in
//            self?.currentNumber = value
//        }
    }
}

struct AsyncStreamBootcamp: View {
    
    @StateObject private var viewModel = AsyncStreamViewModel()
    
    var body: some View {
        ZStack {
            Text("\(viewModel.currentNumber)")
        }
        .onAppear {
            viewModel.onViewAppear()
        }
    }
}

#Preview {
    AsyncStreamBootcamp()
}

//
//  CheckedContinuation.swift
//  ConcurrencySwift
//
//  Created by Вадим Мартыненко on 17.09.2023.
//

import SwiftUI

class CheckedContinuationManager {
    func getData(url: URL) async throws -> Data {
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            
            return data
        } catch {
            throw error
        }
    }
    
    func getData2(url: URL) async throws -> Data { // мы должны использовать resume именно один раз в нашем коде, не больше не меньше
        
        // withCheckedContinuation или withCheckedThrowingContinuation нужен для api которые не оптимизированны под swift concurrency (async, await, task)
        
        return try await withCheckedThrowingContinuation({ continuation in
            // используем api, которое не оптимизированно под swift concurrency
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }.resume()
        })
    }
    
    private func getHeartFromDataBase(completionHandler: @escaping (_ image: UIImage) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5){
            completionHandler(UIImage(systemName: "heart.fill")!)
        }
    }
    
    func getHeartFromDataBase() async -> UIImage {
        return await withCheckedContinuation({ continuation in
            getHeartFromDataBase { image in
                continuation.resume(returning: image)
            }
        })
    }
}

class CheckedContinuationViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    
    let manager = CheckedContinuationManager()
    
    func getImage() async {
        guard let url = URL(string: "https://loremflickr.com/320/240") else { return }
        
        do{
            let data = try await manager.getData2(url: url)
            
            if let image = UIImage(data: data) {
                await MainActor.run(body: {
                    self.image = image
                })
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getHeart() async {
        let image = await manager.getHeartFromDataBase()
        self.image = image
    }
}

struct CheckedContinuation: View {
    
    @StateObject private var viewModel = CheckedContinuationViewModel()
    
    var body: some View {
        ZStack{
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            await viewModel.getHeart()
        }
    }
}

struct CheckedContinuation_Previews: PreviewProvider {
    static var previews: some View {
        CheckedContinuation()
    }
}

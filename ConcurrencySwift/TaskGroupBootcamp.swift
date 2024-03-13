//
//  TaskGroupBootcamp.swift
//  ConcurrencySwift
//
//  Created by Вадим Мартыненко on 17.09.2023.
//

import SwiftUI

class TaskGroupBootcampManager {
    
    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        
       // let urlString = "https://loremflickr.com/320/240"
        
        let urlStrings: [String] = [
            "https://loremflickr.com/320/240",
            "https://loremflickr.com/320/240",
            "https://loremflickr.com/320/240",
            "https://loremflickr.com/320/240",
            "https://loremflickr.com/320/240",
            "https://loremflickr.com/320/240"
        ]
        
      //  withTaskGroup(of: <#T##Sendable.Protocol#>, body: <#T##(inout TaskGroup<Sendable>) async -> GroupResult#>) - используется если в body не будет вызываться throws функция так как у наша функция fetchImage имеет throws мы используем withThrowingTaskGroup
        
        return try await withThrowingTaskGroup(of: UIImage?.self, body: { group in
            var images: [UIImage] = []
            images.reserveCapacity(urlStrings.count) // Заразервирует достаточно места в памяти для хранения (используется для оптимизации)
            
            for urlString in urlStrings {
                group.addTask {
                    try? await self.fetchImage(urlString: urlString)
                }
                
                try Task.checkCancellation()
            }
            
//            for _ in 1...100 {
//                group.addTask(priority: .background) {
//                    try await self.fetchImage(urlString: urlString)
//                }
//            }
                        
            for try await resultTask in group {
                if let resultTask = resultTask {
                    images.append(resultTask)
                }
            }
            
            return images
        })
    }
    
    func fetchImages(urlString: String) async throws -> [UIImage] {
        async let fetchImage1 = fetchImage(urlString: urlString)
        async let fetchImage2 = fetchImage(urlString: urlString)
        async let fetchImage3 = fetchImage(urlString: urlString)
        async let fetchImage4 = fetchImage(urlString: urlString)
        
        let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
        
        return [image1, image2, image3, image4]
    }
    
    private func fetchImage(urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badServerResponse)
            }
        } catch {
            throw error
        }
    }
}

class TaskGroupBootcampViewModel: ObservableObject {
    @Published var images: [UIImage] = []
    
    private let manager = TaskGroupBootcampManager()
    
    private let urlString = "https://loremflickr.com/320/240"
    
    func getImages() async {
        if let images = try? await manager.fetchImagesWithTaskGroup() {
            self.images.append(contentsOf: images)
        }
    }
}

struct TaskGroupBootcamp: View {
    
    @StateObject private var viewModel = TaskGroupBootcampViewModel()
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ScrollView{
            LazyVGrid(columns: columns) {
                ForEach(viewModel.images, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 150)
                }
            }
        }
        .navigationTitle("TaskGroup")
        .task {
            await viewModel.getImages()
        }
    }
}

struct TaskGroupBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        TaskGroupBootcamp()
    }
}

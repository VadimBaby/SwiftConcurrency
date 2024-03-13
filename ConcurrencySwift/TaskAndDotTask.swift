//
//  TaskAndDotTask.swift
//  ConcurrencySwift
//
//  Created by Вадим Мартыненко on 16.09.2023.
//

import SwiftUI

class TaskAndDotTaskViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    func fetchImage() async {
        do{
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            guard let url = URL(string: "https://loremflickr.com/320/240") else { return }
            
//            for x in array {
//
//                // some code
//
//                Task.checkCancellation()
//            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run(body: {
                self.image = UIImage(data: data)
                print("Picture has appeared")
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        do{
            guard let url = URL(string: "https://loremflickr.com/320/240") else { return }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            
            await MainActor.run(body: {
                self.image2 = UIImage(data: data)
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct TaskAndDotTaskNavigation: View {
    var body: some View {
        NavigationStack{
            NavigationLink("Click Me!!!", destination: TaskAndDotTask())
        }
    }
}

struct TaskAndDotTask: View {
    
    @StateObject private var viewModel = TaskAndDotTaskViewModel()
    
  //  @State private var fetchImageTask: Task<(), Never>? = nil
    
    var body: some View {
        VStack{
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
            }
            if let image = viewModel.image2 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
            }
        }
        .task { // task automatically cancel that task, but remember Task.checkCancellation()
            
            await viewModel.fetchImage()
        }
        .task {
            await viewModel.fetchImage2()
        }
//        .onDisappear{
//            fetchImageTask?.cancel()
//        }
//        .onAppear{
//            fetchImageTask = Task(priority: .background) {
//               // await Task.yield()
//                await viewModel.fetchImage()
//            }
//            Task(priority: .high){
//                await viewModel.fetchImage2()
//            }
//        }
    }
}

struct TaskAndDotTask_Previews: PreviewProvider {
    static var previews: some View {
        TaskAndDotTask()
    }
}

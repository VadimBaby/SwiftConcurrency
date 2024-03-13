//
//  AsyncLet.swift
//  ConcurrencySwift
//
//  Created by Вадим Мартыненко on 16.09.2023.
//

import SwiftUI

struct AsyncLet: View {
    
    @State private var images: [UIImage] = []
    @State private var title: String = "Async Let 🏀"
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack{
            ScrollView{
                LazyVGrid(columns: columns) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle(title)
            .onAppear{
                Task{
                    do{
                        async let fetchImage1 = fetchImage()
                        async let fetchTitle = fetchTitle()
                        async let fetchImage2 = fetchImage()
                        async let fetchImage3 = fetchImage()
                        async let fetchImage4 = fetchImage()
                        
                        let (image1, title, image2, image3, image4) = await (try fetchImage1, fetchTitle, try fetchImage2, try fetchImage3, try fetchImage4)
                        
                        self.images.append(contentsOf: [image1, image2, image3, image4])
                        
                        self.title = title
                        
                    } catch {
                        throw error
                    }
                }
            }
        }
    }
    
    func fetchTitle() async -> String {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        return "NEW TITLE!!!"
    }
    
    func fetchImage() async throws -> UIImage {
        guard let url = URL(string: "https://loremflickr.com/320/240") else { throw URLError(.badURL) }
        
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let image = UIImage(data: data) else { throw URLError(.dataNotAllowed)}
            
            return image
        } catch {
            throw error
        }
    }
}

struct AsyncLet_Previews: PreviewProvider {
    static var previews: some View {
        AsyncLet()
    }
}

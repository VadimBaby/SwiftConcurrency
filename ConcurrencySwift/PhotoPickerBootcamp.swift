//
//  PhotoPickerBootcamp.swift
//  ConcurrencySwift
//
//  Created by Вадим Мартыненко on 10.10.2023.
//

import SwiftUI
import PhotosUI

@MainActor
final class PhotoPickerBootcampViewModel: ObservableObject {
    
    @Published private(set) var selectedImage: UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    @Published private(set) var selectedImages: [UIImage] = []
    @Published var imageSelections: [PhotosPickerItem] = [] {
        didSet {
            setImages(from: imageSelections)
        }
    }
    
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else { return }
        
        Task {
            do {
                let data = try await selection.loadTransferable(type: Data.self)
                
                guard let data, let uiImage = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                
                selectedImage = uiImage
            } catch {
                print(error)
            }
        }
    }
    
    private func setImages(from selections: [PhotosPickerItem]) {
        Task {
            var images: [UIImage] = []
            for selection in selections {
                let data = try? await selection.loadTransferable(type: Data.self)
                
                guard let data, let uiImage = UIImage(data: data) else { return }
                
                images.append(uiImage)
            }
            
            selectedImages = images
        }
    }
    
}

struct PhotoPickerBootcamp: View {
    
    @StateObject private var viewModel = PhotoPickerBootcampViewModel()
    
    var body: some View {
        VStack{
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(.rect(cornerRadius: 15))
            }
            
            PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                Text("Open the photo picker")
                    .foregroundStyle(Color.red)
            }
            
            if !viewModel.selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false, content: {
                    HStack{
                        ForEach(viewModel.selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 200)
                                .clipShape(.rect(cornerRadius: 15))
                        }
                    }
                })
            }
            
            PhotosPicker(selection: $viewModel.imageSelections, matching: .images) {
                Text("Open the photo picker")
                    .foregroundStyle(Color.blue)
            }
        }
    }
}

#Preview {
    PhotoPickerBootcamp()
}

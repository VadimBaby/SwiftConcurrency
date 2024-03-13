//
//  DoCatchTryThrowsResult.swift
//  ConcurrencySwift
//
//  Created by Вадим Мартыненко on 14.09.2023.
//

import SwiftUI

class DoCatchTryThrowsResultDataManager {
    
    static var instance = DoCatchTryThrowsResultDataManager()
    
    private let isActive: Bool = true
    
    func getTitle() -> Result<String, Error> {
        if isActive {
            return .success("NEW TEXT!!!")
        } else {
            return .failure(URLError(.badURL))
        }
    }
    
    func getTitle2() throws -> String {
        if isActive {
            return "NEW TEXT!!!"
        } else {
            throw URLError(.callIsActive)
        }
    }
    
    func getTitle3() throws -> String {
        return "FINAL TEXT"
    }
    
    func getError() throws -> String {
        throw URLError(.cancelled)
    }
}

class DoCatchTryThrowsResultViewModel: ObservableObject {
    
    @Published var text: String = "Start texting..."
    
    private var DataManager = DoCatchTryThrowsResultDataManager.instance
    
    func fetchTitle() {
        let result = DataManager.getTitle()
        
        switch result {
        case .success(let newTitle):
            self.text = newTitle
        case .failure(let error):
            self.text = error.localizedDescription
        }
    }
    
    func fetchTitle2() {
        do{
            let result = try DataManager.getTitle2()
            self.text = result
        } catch {
            self.text = error.localizedDescription
        }
    }
    
    func fetchTitle3() {
        do{
            let firstResult = try DataManager.getError()
            self.text = firstResult
            
            let secondFirst = try DataManager.getTitle3()
            self.text = secondFirst
            
        } catch {
            self.text = error.localizedDescription
        }
    }
    
    func fetchTitle4() {
        do{
            let firstResult = try? DataManager.getError()
            if let firstResult = firstResult {
                self.text = firstResult
            }
            
            let secondFirst = try DataManager.getTitle3()
            self.text = secondFirst
            
        } catch {
            self.text = error.localizedDescription
        }
    }
    
    func fetchTitle5() {
        let result = try? DataManager.getTitle3()
        
        if let result = result {
            self.text = result
        }
    }
}

struct DoCatchTryThrowsResult: View {
    
    @StateObject private var viewModel = DoCatchTryThrowsResultViewModel()
    
    var body: some View {
        Text(viewModel.text)
            .frame(width: 300, height: 300)
            .background(Color.blue)
            .onTapGesture {
                viewModel.fetchTitle4()
            }
    }
}

struct DoCatchTryThrowsResult_Previews: PreviewProvider {
    static var previews: some View {
        DoCatchTryThrowsResult()
    }
}

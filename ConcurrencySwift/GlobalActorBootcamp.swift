//
//  GlobalActorBootcamp.swift
//  ConcurrencySwift
//
//  Created by Вадим Мартыненко on 06.10.2023.
//

import SwiftUI

@globalActor struct MyFirstGlobalActor {
    
    static var shared = MyNewDataManager()
    
}

actor MyNewDataManager {
    
    func getDataFromDataBase() -> [String] {
        return ["One", "Two", "Three", "Four"]
    }
}

/*
 
 С помощью обозначений по типу @MainActor, @MyFirstGlobalActor мы можем указать какая переменная функия или переменная работает в какой actor'е
 
 Например
 
Наш UI зависит и изменяется когда изменяется переменная dataArray, а любое изменения UI происходит в main thread то есть MainActor, поэтому мы можем помететь эту переменную как @MainActor, тем самым указываем что изменение этой переменной должно происходить строго в main thread
 
 функция getData использует результат из функции которая у нас в actor MyNewDataManager. Мы можем создать структуру с протоколом @globalActor и теперь мы можем функцию getData которая находится во viewModel пометить в
    @MyFirstGlobalActor тем самым указав что это функция работает с нашим actor
 
 
 Мы можем перед class использовать @MainActor и тем самым мы все параментры класса присваеваем к @MainActor, если нам нужно к примеру присвоить к @MainActor только одну переменную то мы можем просто написать @MainActor в начале создания переменной (вместо @MainActor можем быть любой actor)
 */

@MainActor class GlobalActorBootcampViewModel: ObservableObject { // it means that everything in this call is going to be in MainActor (in this case)
    
    @MainActor @Published var dataArray: [String] = [] // marked that this var is going to be on main actor (main thread in other words)
    
    let manager = MyFirstGlobalActor.shared
    
    @MyFirstGlobalActor func getData() async { // marked that this func is going to be on MyFirstGlobal Actor
        
        let data = await manager.getDataFromDataBase()
        await MainActor.run {
            self.dataArray = data
        }
    }
}

struct GlobalActorBootcamp: View {
    
    @StateObject private var viewModel = GlobalActorBootcampViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.getData()
        }
    }
}

#Preview {
    GlobalActorBootcamp()
}

//
//  ActorBootcamp.swift
//  ConcurrencySwift
//
//  Created by Вадим Мартыненко on 05.10.2023.
//

import SwiftUI

// thread safe class (USE ACTOR)

class MyDataManagerHere {
    
    static let instance = MyDataManagerHere()
    
    private init() {}
    
    var data: [String] = []
    
    private let lock = DispatchQueue(label: "com.MyApp.MyDataManagerHere")
    
    func getRandomData(completionHandler: @escaping (_ title: String?) -> Void) {
        lock.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            completionHandler(self.data.randomElement())
        }
    }
    
    nonisolated func getSavedData() -> String { // this func is not await func
        return "New Data"
    }
}

// YOU SHOULD USE ACTOR FOR THREAD SAFE

actor MyActorDataManagerHere {
    
    static let instance = MyActorDataManagerHere()
    
    private init() {}
    
    var data: [String] = []
    
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return self.data.randomElement()
    }
}

struct HomeView: View {
    
    let manager = MyActorDataManagerHere.instance
    
    @State private var text: String = ""
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack{
            Color.gray.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer, perform: { _ in
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
        })
    }
}

struct BrowseView: View {
    
    let manager = MyDataManagerHere.instance
    
    @State private var text: String = ""
    
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack{
            Color.yellow.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer, perform: { _ in
            DispatchQueue.global(qos: .background).async {
                manager.getRandomData { title in
                    if let data = title {
                        DispatchQueue.main.async {
                            self.text = data
                        }
                    }
                }
            }
        })
    }
}

struct ActorBootcamp: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    ActorBootcamp()
}

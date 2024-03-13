//
//  SendableBootcamp.swift
//  ConcurrencySwift
//
//  Created by Вадим Мартыненко on 06.10.2023.
//

import SwiftUI

actor CurrentUserManager {
    func updateDataBase(userInfo: MyClassUserInfo) {
        
    }
}

struct MyUserInfo: Sendable { // it means that this struck is thread safe
    var name: String
}

/*
 
 - Struct, Enum, String, Int, etc.
 
 these value types is thread safe by default
 
 */

final class MyClassUserInfo: @unchecked Sendable { // its very dangeraous, so try to dont do like that
    
    private var name: String
    
    let queue = DispatchQueue(label: "com.MyApp.MyClassUserInfo")
    
    init(name: String) {
        self.name = name
    }
    
    func updateName(name: String) {
        queue.async {
            self.name = name
        }
    }
}

class SendableBootcampViewModel: ObservableObject {
    let manager = CurrentUserManager()
    
    func updateCurrentUserInfo() async {
        let userInfo = MyClassUserInfo(name: "User Info")
        
        await manager.updateDataBase(userInfo: userInfo)
    }
}

struct SendableBootcamp: View {
    
    @StateObject private var viewModel = SendableBootcampViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .task {
                
            }
    }
}

#Preview {
    SendableBootcamp()
}

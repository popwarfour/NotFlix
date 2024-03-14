//
//  ContentView.swift
//  DeleteMe
//
//  Created by Anders on 3/6/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MyParent()
    }
}

#Preview {
    ContentView()
}

// MARK: - Parent

struct MyParent: View {
    
    typealias ViewModel = ParentViewModel
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            Text("Parent Perspective: \(viewModel)")
            Button("Increment", action: viewModel.didPress)
            
            Divider()
            
            MyChild_Option1(
                viewModel: viewModel.childOneViewModel(),
                didPress: viewModel.didPress
            )
            
            Divider()
            
            MyChild_Option2(
                viewModel: viewModel.childTwoViewModel(),
                childActions: viewModel
            )
            
            Divider()
            
            MyChild_Option3(
                viewModel: viewModel.childThreeViewModel()
            )
        }
    }
    
}

final class ParentViewModel: ObservableObject {
    @Published var texts = [String]()
}

protocol ChildActions {
    func didPress()
}

extension ParentViewModel: ChildActions {

    func childOneViewModel() -> MyChild_Option1.ViewModel {
        .init(texts: texts)
    }
    
    func childTwoViewModel() -> MyChild_Option2.ViewModel {
        .init(texts: texts)
    }
    
    func childThreeViewModel() -> MyChild_Option3.ViewModel {
        .init(texts: texts,
              didPress: didPress)
    }

    func didPress() {
        texts.append("Another one")
    }
    
}

// MARK: - Option 2 (Struct / Closure)

struct MyChild_Option1: View {
    
    struct ViewModel {
        let texts: [String]
    }
    
    /// INPUTS passed down to configure the view
    let viewModel: ViewModel
    /// ACTIONS passed back up the view hierarchy
    let didPress: () -> Void
    
    var body: some View {
        VStack {
            ForEach(viewModel.texts, id: \.self) {
                Text("Child 1 - \($0)")
            }
            Button("Increment", action: didPress)
        }
    }
    
}

// MARK: - Option 2 (Struct / Delegate)

struct MyChild_Option2: View {
    
    struct ViewModel {
        let texts: [String]
    }
    
    /// INPUTS passed down to configure the view
    let viewModel: ViewModel
    /// ACTIONS passed back up the view hierarchy
    let childActions: ChildActions
    
    var body: some View {
        VStack {
            ForEach(viewModel.texts, id: \.self) {
                Text("Child 2 - \($0)")
            }
            Button("Increment", action: childActions.didPress)
        }
    }
    
}


// MARK: - Option 3 (ObservedObject / Closure)

struct MyChild_Option3: View {
    
    final class ViewModel: ObservableObject {
        @Published var texts: [String]
        
        /// ACTIONS passed back up the view hierarchy
        let didPress: () -> Void
        
        init(texts: [String], didPress: @escaping () -> Void) {
            self.texts = texts
            self.didPress = didPress
        }
    }
    
    /// INPUTS passed down to configure the view
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            ForEach(viewModel.texts, id: \.self) {
                Text("Child 3 - \($0)")
            }
            Button("Increment", action: viewModel.didPress)
        }
    }
    
}

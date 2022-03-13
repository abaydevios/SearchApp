//
//  ContentView.swift
//  Shared
//
//  Created by Shaikenov Abay on 10.03.2022.
//

import SwiftUI
import Kingfisher

struct RSS: Decodable {
    let feed: Feed
}

struct Feed: Decodable {
    let results: [Result]
}

struct Result: Decodable, Hashable{
    let name, artworkUrl100, releaseDate: String
}

class GridViewModel: ObservableObject {
    
    @Published var items = 0..<5
    @Published var results = [Result]()
    
    
    init() {
        // json decoding simulation
            guard let url = URL(string: "https://rss.applemarketingtools.com/api/v2/us/apps/top-free/50/apps.json") else { return }
            URLSession.shared.dataTask(with: url) { (data, resp, err) in
               // check responce status and err
                guard let data = data else { return }
                do {
                    let rss = try JSONDecoder().decode(RSS.self, from: data)
                    print(rss, "777")
                    self.results = rss.feed.results
                } catch {
                    print("Failed to decode 777 \(error)")
                }
            }.resume()
        }
}


struct ContentView: View {
    
    @ObservedObject var vm = GridViewModel()
    
    @State var searchText = ""
    @State var isSearching = false
    var body: some View {
        NavigationView {
            ScrollView {
                
                HStack{
                    HStack {
                        TextField("Search app", text: $searchText)
                            .padding(.leading, 24)
                    }
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .onTapGesture(perform: {
                        isSearching = true
                    })
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Spacer()
                            
                            if isSearching {
                                Button(action: { searchText = "" }, label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .padding(.vertical)
                                })
                            }
                        }
                        .padding(.horizontal, 32)
                        .foregroundColor(.gray)
                    )
                    .transition(.move(edge: .trailing))
                    .animation(.spring())
                    
                    if isSearching {
                        Button(action: {
                            isSearching = false
                            searchText = ""
                            
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            
                        }) {
                            Text("Cancel")
                                .padding(.trailing)
                                .padding(.leading, -12)
                        }
                        .transition(.move(edge: .trailing))
                        .animation(.spring())
                    }
                    
                }
                
                LazyVGrid(columns: [
                    GridItem(.flexible(minimum: 120, maximum: 200), spacing: 5, alignment: .top),
                    GridItem(.flexible(minimum: 120, maximum: 200), spacing: 5, alignment: .top),
                    GridItem(.flexible(minimum: 120, maximum: 200), alignment: .top)
                ], spacing: 15) {
                    ForEach(vm.results.filter({"\($0)".contains(searchText) || searchText.isEmpty}), id: \.self) { app in
                        VStack(alignment: .leading, spacing: 4) {
                           
                            KFImage(URL(string: app.artworkUrl100))
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(22)
                            Text(app.name)
                                .font(.system(size: 10, weight: .semibold))
                                .padding(.top, 4)
                            Text(app.releaseDate)
                                .font(.system(size: 9, weight: .regular))

                            Spacer()
                        }
                        .padding(.horizontal)
//                        .background(.yellow)
                    }
                }.padding(.horizontal)
            }.navigationTitle("Grid Search LBTA")
        }
    }
}
                                              

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


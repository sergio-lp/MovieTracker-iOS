//
//  SearchButton.swift
//  MovieTrack
//
//  Created by Aluno02 on 07/05/22.
//  Copyright © 2022 sergio-lp. All rights reserved.
//

import SwiftUI

struct SearchButton: View {
    @State var searchText: String
    @State var isInSearch: Bool
    @ObservedObject var movieList: MovieList
    
    
    
    var body: some View {
        Button(action: {
            print("osojodjwojd")
            if (!self.isInSearch) {
                self.isInSearch = true
                print("opapaaa")
                
                let searchUrl = "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&language=pt-BR&page=1&include_adult=false&query=\(self.searchText)"
                
                print("Search url was: \(searchUrl)")
                
                    URLSession.shared.dataTask(with: URL(string: searchUrl)!, completionHandler: {data, response, error in
                        guard let data = data, error == nil else {
                            print("An error has occurred when fetching from API.")
                            return
                        }
                        
                        var result: SearchResponse?
                        do {
                            result = try JSONDecoder().decode(SearchResponse.self, from: data)
                        } catch {
                            print("An error has ocurred when deconding response. \(error)")
                            return
                        }
                        
                        guard let res = result else {
                            print("An error has occured when checking if response was successful.")
                            return
                        }
                        
                        guard let movies = res.results else {
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self.movieList.movies = movies
                        }
                        
                    }
                    ).resume()
            } else {
                self.searchText = ""
                self.movieList.movies.removeAll()
                self.isInSearch = false
            }
            
            
            
        }, label: {
            if (!isInSearch) {
                withAnimation(.easeInOut) {
                Image("search")
                    .resizable()
                    .padding()
                    .frame(width: 60, height: 60)
                    .transition(.scale)
                }
            } else {
                withAnimation(.easeInOut) {
                Image(systemName: "stop")
                    .resizable()
                    .padding()
                    .frame(width: 60, height: 60)
                    .transition(.scale)
                }
            }
        })
    }
}

struct SearchButton_Previews: PreviewProvider {
    static var previews: some View {
        SearchButton(searchText: "", isInSearch: false, movieList: MovieList())
    }
}

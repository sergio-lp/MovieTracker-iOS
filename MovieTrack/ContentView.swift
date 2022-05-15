//
//  ContentView.swift
//  MovieTrack
//
//  Created by Aluno02 on 07/05/22.
//  Copyright © 2022 sergio-lp. All rights reserved.
//

import SwiftUI
import Combine

//TODO: Adicionar persistência de dados (inserir e remover filme dos assistidos) e visualização do tutorial
//TODo: Mostrar os filmes assistidos na tela inicial quando não houver pesquisa
//TODO: Infelizmente não consegui adicionar essas funções relacionadas à persistência de dados por falta de tempo...

class AppSettings: ObservableObject {
    @Published var currentPage: Int = 0
}

class MovieList: ObservableObject {
    @Published var movies: [Movie] = [Movie]()
}

struct Movie: Codable, Hashable {
    let title: String?
    let poster_path: String?
    let release_date: String?
    let vote_average: Float?
    let overview: String?
    let backdrop_path: String?
}

let apiKey = "0ceff43a4caefbe0a1757949abf184db"
let imgUrl = "https://image.tmdb.org/t/p/w500"

struct SearchResponse: Codable {
    let results: [Movie]?
}

class ImageLoader: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }
    
    init(urlString:String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.data = data
            }
        }
        task.resume()
    }
}
struct ImageView: View {
    @ObservedObject var imageLoader:ImageLoader
    @State var image:UIImage = UIImage()
    
    init(withURL url:String) {
        imageLoader = ImageLoader(urlString:url)
    }
    
    var body: some View {
        
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width:130, height:200)
            .onReceive(imageLoader.didChange) { data in
                self.image = UIImage(data: data) ?? UIImage()
        }
    }
}

struct MovieView: View {
    let movie: Movie
    
    var body: some View {
        HStack {
            if(movie.poster_path != nil && movie.poster_path != "") {
                ImageView(withURL: imgUrl + movie.poster_path!)
            } else {
                VStack {
                    Image("movieicon")
                        .resizable()
                        .padding(20)
                        .aspectRatio(contentMode: .fit)
                }
                .frame(
                    width: 130,
                    height: 200
                ).background(Color.gray)
            }
            
            VStack {
                Text(movie.title!)
                    .fontWeight(.bold)
                    .padding(EdgeInsets.init(top: 5, leading: 10, bottom: 0, trailing: 10))
                    .font(.system(size: 18)).frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        alignment: .leading
                ).multilineTextAlignment(.leading)
                
                Text("Data de lançamento: \(movie.release_date!)")
                    .padding(EdgeInsets.init(top: 5, leading: 10, bottom: 0, trailing: 10))
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        alignment: .leading
                )
                
                Text(String("Avaliação: \(movie.vote_average!)"))
                    .padding(EdgeInsets.init(top: 5, leading: 10, bottom: 0, trailing: 10))
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        alignment: .leading
                )
                
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject var appSettings: AppSettings
    @State var isInSearch: Bool
    @State var searchText = ""
    @ObservedObject var movieList: MovieList
    
    
    var body: some View {
        NavigationView {
            if (self.appSettings.currentPage != -1) {
                WalktroughScreen(appSettings: appSettings)
            } else {
                VStack {
                    HStack(spacing: 20) {
                        TextField("Pesquise um filme...", text: $searchText)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        Button(action: {
                            if (!self.isInSearch) {
                                self.isInSearch = true
                                
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
                                    Image("close")
                                        .resizable()
                                        .padding()
                                        .frame(width: 60, height: 60)
                                        .transition(.scale)
                                }
                            }
                        })
                        
                    }
                    
                    Spacer()
                    
                    List(movieList.movies, id: \.self) { eachMovie in
                        NavigationLink(destination: MovieDetailsScreen(movieArg: eachMovie), label: {
                            MovieView(movie: eachMovie)
                        })
                    }.listStyle(PlainListStyle())
                    
                }.navigationBarTitle("MovieTracker")
                    .padding()
                
            }
        }.environmentObject(appSettings)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(appSettings: AppSettings(), isInSearch: false, movieList: MovieList())
    }
}

struct WalktroughScreen: View {
    @ObservedObject var appSettings: AppSettings
    
    var body: some View {
        ZStack {
            if (appSettings.currentPage == 0) {
                IntroView(title: "Bem vindo ao app Movie Tracker", description: "Se você quer manter um catálogo de filmes que assistiu, está no app certo!", image: "movieicon", color: "color2")
                    .transition(.scale)
            }
            
            if (appSettings.currentPage == 1) {
                
                IntroView(title: "Vamos lá!", description: "Obrigado por estar aqui, clique em próximo e vamos começar!", image: "happy", color: "color1")
                    .transition(.scale)
            }
            
            if (appSettings.currentPage == 2) {
                
            }
        }.overlay(Button(action: {
            withAnimation(.easeInOut) {
                if (self.appSettings.currentPage < 1) {
                    self.appSettings.currentPage += 1
                } else {
                    self.appSettings.currentPage = -1
                }
            }
        }, label: {
            Image(systemName: "chevron.right")
                .foregroundColor(Color.black)
                .frame(width: 60, height: 60)
                .background(Color.white)
                .clipShape(Circle())
        }), alignment: .bottom)
    }
}

struct IntroView: View {
    var title: String
    var description: String
    var image: String
    var color: String
    
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                
                HStack {
                    Text("Bem vindo ao MovieTracker!").kerning(1.4)
                        .foregroundColor(Color(UIColor.white))
                        .fontWeight(.bold)
                    Button(action: {}, label: {
                        Text("Pular")
                            .kerning(1.2)
                            .fontWeight(.bold)
                    })
                }.padding()
                
                Spacer()
                
                
                Image(image)
                    .resizable()
                    .frame(width: 250, height: 250, alignment: .center)
                    .aspectRatio(contentMode: .fit)
                
                Text(title)
                    .foregroundColor(Color(UIColor.white))
                    .fontWeight(.bold)
                    .padding(.top)
                    .font(.system(size: 22))
                
                Text(description)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(UIColor.white))
                
                
                Spacer()
            }.frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity
            )
                .background(Color(color).edgesIgnoringSafeArea(.all))
        }
    }
    
}


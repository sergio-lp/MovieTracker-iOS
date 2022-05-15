    //
    //  MovieDetailsScreen.swift
    //  MovieTrack
    //
    //  Created by Aluno02 on 08/05/22.
    //  Copyright © 2022 sergio-lp. All rights reserved.
    //
    
    import SwiftUI
    
    let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let savedMoviesFileUrl = documentsUrl.appendingPathComponent("movie_tracker_db.json").appendingPathExtension("doc")
    var jsonWatched = NSData(contentsOf: savedMoviesFileUrl)
    

    
    
    struct MovieDetailsScreen: View {
        @State var movieArg: Movie?
        
        
        
        var body: some View {
            let movie = self.movieArg ?? Movie(title: "Sem título", poster_path: "", release_date: "Sem data de lançamento", vote_average: 0, overview: "Sem sinopse", backdrop_path: "")
            
            return ScrollView {
                VStack {
                    
                    if (movie.backdrop_path != nil && movie.backdrop_path != "") {
                        PosterView(withURL: movie.backdrop_path!)
                    } else {
                        VStack {
                            Image("movieicon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(EdgeInsets.init(top: 100, leading: 0, bottom: 30, trailing: 0))
                                .background(Color.gray)
                                .frame(minWidth: 0,
                                       maxWidth: .infinity,
                                       minHeight: 0,
                                       maxHeight: 200)
                                .background(Color.gray)
                        }.frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0,
                            maxHeight: 200
                        )
                            .background(Color.gray)
                            .edgesIgnoringSafeArea(.all)
                            .background(Color.gray)
                    }
                    
                    
                    HStack {
                        if(movie.poster_path != nil && movie.poster_path != "") {
                            ImageView(withURL: imgUrl + movie.poster_path!)
                        } else {
                            VStack {
                                VStack {
                                    Image("movieicon")
                                        .resizable()
                                        .padding(8)
                                        .aspectRatio(contentMode: .fit)
                                    
                                }
                                .frame(
                                    width: CGFloat(130),
                                    height: CGFloat(200)
                                    
                                ).background(Color.gray)
                            }
                            .frame(
                                alignment: .leading
                            )
                        }
                        
                        VStack {
                            
                            Text(movie.title!)
                                .fontWeight(.bold)
                                .font(.system(size: 22))
                                .padding(EdgeInsets.init(top: 0, leading: 5, bottom: 5, trailing: 5))
                                .frame(
                                    minWidth: 0,
                                    maxWidth: .infinity,
                                    minHeight: 0,
                                    alignment: .topLeading
                            )
                            
                            Text(movie.release_date!)
                                .multilineTextAlignment(.leading)
                                .padding(EdgeInsets.init(top: 0, leading: 5, bottom: 5, trailing: 5))
                                .frame(
                                    minWidth: 0,
                                    maxWidth: .infinity,
                                    minHeight: 0,
                                    alignment: .topLeading
                            )
                            
                            Text(String("Nota média: \(movie.vote_average!)"))
                                .multilineTextAlignment(.leading)
                                .padding(EdgeInsets.init(top: 0, leading: 5, bottom: 5, trailing: 5))
                                .frame(
                                    minWidth: 0,
                                    maxWidth: .infinity,
                                    minHeight: 0,
                                    alignment: .topLeading
                            )
                            
                            Spacer()
                        }
                    }.frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: 200,
                        alignment: .topLeading
                    )
                        .padding(EdgeInsets.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                    
                    Text("Sinopse")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0,
                            alignment: .topLeading
                    )
                        .padding(EdgeInsets.init(top: 16, leading: 16, bottom: 16, trailing: 16))
                    
                    Text(movie.overview!)
                        .multilineTextAlignment(.leading)
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0,
                            alignment: .topLeading
                    )
                        .padding(EdgeInsets.init(top: 0, leading: 16, bottom: 16, trailing: 16))
                    
                    Spacer()
                }
            }
        }
    }
    
    struct 	PosterView: View {
        @ObservedObject var imageLoader:ImageLoader
        @State var image:UIImage = UIImage()
        
        init(withURL url:String) {
            imageLoader = ImageLoader(urlString: "https://image.tmdb.org/t/p/w500" + url)
        }
        
        var body: some View {
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: 300
            )
                .onReceive(imageLoader.didChange) { data in
                    self.image = UIImage(data: data) ?? UIImage()
            }
        }
    }
    
    struct MovieDetailsScreen_Previews: PreviewProvider {
        static var previews: some View {
            MovieDetailsScreen(movieArg: nil)
        }
    }

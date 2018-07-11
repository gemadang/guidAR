//
//  MovieKeys.swift
//  MovieListApp
//
//  Created by Geri Elise Madanguit on 3/27/18.
//  Copyright © 2018 GeriMadanguit. All rights reserved.
//

import Foundation

struct MovieData: Decodable {
    let id: Int?
    let poster_path: String?
    let backdrop: String?
    let title: String?
    let releaseDate: String?
    let rating: Double?
    let overview: String?
    let genres: [MovieGenre]
    
    private enum codingKeys: String, CodingKey{
        case id, posterPath = "poster_path", backdrop = "backdrop_path", title, releaseDate = "release_date", rating = "vote_average", overview, genres
    }
}

struct MovieGenre: Decodable{
    let id: Int?
    let name: String?
}

struct MovieInfo: Decodable {
    let id: Int?
    let posterPath: String?
    let title: String?
    private enum CodingKeys: String, CodingKey {
        case id, posterPath = "poster_path", title
    }
}

struct MovieImages: Decodable {
    let id: Int?
    let posters: [PosterInfo]
    
    private enum CodingKeys: String, CodingKey{
        case id, posters = "posters"
    }
}

struct PosterInfo: Decodable {
    let filePath: String?
    let height: Int?
    
    private enum CodingKeys: String, CodingKey{
        case filePath = "file_path", height
    }
}

struct MovieResults: Decodable {
    let page: Int?
    let numResults: Int?
    let numPages: Int?
    var movies: [MovieInfo]
    
    private enum CodingKeys: String, CodingKey {
        case page, numResults = "total_results", numPages = "total_pages", movies = "results"
    }
}


//
//  Question.swift
//  Quiz
//
//  Created by ILLIA HARKAVY on 25.11.20.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct TriviaResponse: Codable {
    let response_code: Int
    let results: [Question]
}

struct Question: Codable, Equatable {
    
    let category: String
    let type: Type
    let difficulty: Difficulty
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
    
    enum `Type`: String, Codable {
        case boolean
        case multiple
    }
    
    enum Difficulty: String, Codable {
        case easy
        case medium
        case hard
        
        var points: Int {
            switch self {
            case .easy:
                return 10
            case .medium:
                return 20
            case .hard:
                return 30
            }
        }
        
        var name: String {
            switch self {
            case .easy:
                return "Easy"
            case .medium:
                return "Medium"
            case .hard:
                return "Hard"
            }
        }
    }
}

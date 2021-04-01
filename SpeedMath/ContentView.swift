//
//  ContentView.swift
//  SpeedMath
//
//  Created by Jan Bjelicic on 01/04/2021.
//

import SwiftUI

enum Position {
    case answered, current, upcoming
}

struct Question {
    let text: String
    let actualAnswer: String
    var userAnswer = ""
    var paddingAmount = 0
    
    init() {
        let left = Int.random(in: 1...10)
        let right = Int.random(in: 1...10)
        
        text = "\(left) + \(right) = "
        actualAnswer = "\(left + right)"
        
        if left < 10 {
            paddingAmount += 1
        }
        
        if right < 10 {
            paddingAmount += 1
        }
    }
}

struct QuestionRow: View {
    var question: Question
    var position: Position
    var positionColor: Color {
        if position == .answered {
            if question.actualAnswer == question.userAnswer {
                return Color.green.opacity(0.8)
            } else {
                return Color.red.opacity(0.8)
            }
        } else if position == .upcoming {
            return Color.black.opacity(0.5)
        } else {
            return .blue
        }
    }
    
    var body: some View {
        HStack {
            HStack(spacing: 0) {
                if question.paddingAmount > 0 {
                    Text(String.init(repeating: " ", count: question.paddingAmount))
                }
                Text(question.text)
            }
            .padding([.top, .bottom, .leading])
            
            ZStack {
                Text(" ")
                    .padding()
                    .frame(width: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(positionColor)
                    )
                Text(question.userAnswer)
            }
        }
        .font(.system(size: 48, weight: .regular, design: .monospaced))
        .foregroundColor(.white)
    }
    
}

struct ContentView: View {
    @State private var questions = [Question]()
    @State private var currentQuestion = 0
    
    var score: Int {
        var total = 0
        for i in 0..<currentQuestion {
            if questions[i].actualAnswer == questions[i].userAnswer {
                total += 1
            }
        }
        return total
    }
    
    var body: some View {
        ZStack {
            ForEach(0..<questions.count, id: \.self) { index in
                QuestionRow(question: questions[index], position: position(for: index))
                    .offset(x: 0, y: CGFloat(index * 100) - CGFloat(self.currentQuestion * 100))
            }
            VStack {
                HStack {
                    Spacer()
                    Text("Score: \(score)")
                        .padding()
                        .background(Capsule().fill(Color.white.opacity(0.8)))
                        .animation(nil)
                }
                .font(.largeTitle)
                .foregroundColor(.black)
                .padding()
                Spacer()
            }
            .padding()
        }
        .frame(width: 1000, height: 600)
        .background(LinearGradient(gradient: Gradient(colors: [.blue, .black]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .onAppear(perform: createQuestion)
        .onReceive(NotificationCenter.default.publisher(for: .enterNumber)) { note in
            guard let number = note.object as? Int, currentQuestion < questions.count else { return }
            if questions[currentQuestion].userAnswer.count < 3 {
                questions[currentQuestion].userAnswer += String(number)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .removeNumber)) { _ in
            guard currentQuestion < questions.count else { return }
            _ = questions[currentQuestion].userAnswer.popLast()
        }
        .onReceive(NotificationCenter.default.publisher(for: .submitAnswer)) { _ in
            guard currentQuestion < questions.count else { return }
            if questions[currentQuestion].userAnswer.isEmpty == false {
                withAnimation {
                    currentQuestion += 1
                }
            }
        }
    }
    
    func createQuestion() {
        for _ in 1...50 {
            questions.append(Question())
        }
    }
    
    func position(for index: Int) -> Position {
        if index < currentQuestion {
            return .answered
        } else if index == currentQuestion {
            return .current
        } else {
            return .upcoming
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

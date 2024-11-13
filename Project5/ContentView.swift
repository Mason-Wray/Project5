//
//  ContentView.swift
//  Project5
//
//  Created by Student on 11/13/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            List {
            Section {
                TextField("Enter Your Word", text: $newWord)
                    .textInputAutocapitalization(.never)
            }
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) { } message: {
                Text(errorMessage)
            }
        }
    }
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else {return}
        guard isOriginal(word: answer) else {
            wordError(title: "Word Already Used",message:  "No Imagination?")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "word not possible", message: "cannot spell word from \(rootWord)")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "made up words do not count!")
            return
        }
        withAnimation{
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "cheeseBurger"
                return
            }
        }
        fatalError(".txt file not found from bundle")
    }
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    func isPossible(word: String) -> Bool {
        var TemporaryWord = rootWord
        for letter in word {
            if let pos = TemporaryWord.firstIndex(of: letter) {
                TemporaryWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspellRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspellRange.location == NSNotFound
    }
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

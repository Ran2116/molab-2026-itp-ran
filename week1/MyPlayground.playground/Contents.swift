import Foundation

let choices = ["✊", "✌️", "🖐️"]
let totalRounds = 10

var playerScore = 0
var computerScore = 0
var ties = 0

//random choose from rock, paper and scissors
func randomChoice() -> String {
    return choices.randomElement()!
}

// determine the winner and return a result string
func determineWinner(player: String, computer: String) -> String {
    if player == computer {
        return "Tie"
    }
    if (player == "✊" && computer == "✌️") ||
       (player == "✌️" && computer == "🖐️") ||
       (player == "🖐️" && computer == "✊") {
        return "Player wins"
    }
    return "Computer wins"
}

// play one round and print the result
func playRound(_ roundNumber: Int) {
    let player = randomChoice()
    let computer = randomChoice()
    let result = determineWinner(player: player, computer: computer)

    print("Round \(roundNumber): Player \(player) vs Computer \(computer) → \(result)")
}

//rounds we gonna play
for round in 1...totalRounds {
    playRound(round)
}

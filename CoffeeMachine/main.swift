//
//  main.swift
//  CoffeeMachine
//
//  Created by Дарья Селезнёва on 06.04.2022.
//

import Foundation

struct Ingredients {
    var water: Int
    var coffee: Int
    var milk: Int
}

protocol CoffeeDrink {
    var name: String { get }
    var water: Int { get }
    var coffee: Int { get }
    var milk: Int { get }
}

struct Espresso: CoffeeDrink {
    var name: String = "espresso"
    var water: Int = 40
    var coffee: Int = 10
    var milk: Int = 0
}

struct Cappuchino: CoffeeDrink {
    var name: String = "cappuchino"
    var water: Int = 60
    var coffee: Int = 10
    var milk: Int = 100
}

struct Latte: CoffeeDrink {
    var name: String = "latte"
    var water: Int = 60
    var coffee: Int = 8
    var milk: Int = 140
}

struct CustomDrink: CoffeeDrink {
    var name: String
    var water: Int
    var coffee: Int
    var milk: Int
}


func getInput() -> String {
    let keyboard = FileHandle.standardInput
    let inputData = keyboard.availableData
    let strData = String(data: inputData, encoding: String.Encoding.utf8)!
    return strData.trimmingCharacters(in: CharacterSet.newlines)
}

enum Command: String {
    case on
    case off
    case add
    case check
    case make
    case clean
    case recipe
    case help
    case quit
}

enum Argument: String {
    case water = "w"
    case milk = "m"
    case coffee = "c"
    case espresso = "es"
    case cappuchino = "ca"
    case latte = "la"
}

class CoffeeMachine {
    
    // MARK: - Stored properties
    
    private var isOn: Bool = false
    
    private let cupsBeforeClean: Int = 7
    private var cupsMade: Int = 0
    
    private let waterCapacity: Int = 2000
    private let coffeeCapacity: Int = 500
    private let milkCapacity: Int = 1000
    
    private var ingredients: Ingredients = Ingredients(water: 1000, coffee: 300, milk: 800)
    
    
    // MARK: - Computed properties
    
    private var needsCleaning: Bool { cupsMade == cupsBeforeClean }
    
    private var waterStatus: String { "Water: \(ingredients.water)/\(waterCapacity) ml" }
    private var coffeeStatus: String { "Coffee: \(ingredients.coffee)/\(coffeeCapacity) g" }
    private var milkStatus: String { "Milk: \(ingredients.milk)/\(milkCapacity) ml"}
    private var cleaningStatus: String { cupsMade < cupsBeforeClean ? "Needs cleaning after \(cupsBeforeClean - cupsMade) cups" : "Needs cleaning" }
    
    private var ingredientsStatus: String { [waterStatus, coffeeStatus, milkStatus].joined(separator: ". ") }
    
    // MARK: - Methods
    
    private func turnOn() {
        isOn = true
        print("Coffeemachine is ready to use.")
        print(ingredientsStatus)
        print(cleaningStatus)
    }
    
    private func turnOff() {
        isOn = false
        print("Bye!")
    }
    
    private func add(_ ingredient: inout Int, amount: Int, maxCapacity: Int, name: String, measurementUnit: String) {
        let freeSpace = maxCapacity - ingredient
        let amountToAdd = amount <= freeSpace ? amount : freeSpace
        let warningString = amount <= freeSpace ? "" : "Can only add \(amountToAdd) \(measurementUnit) \(name)\n"
        let oldStatus = "\(ingredient)/\(maxCapacity) " + measurementUnit
        ingredient += amountToAdd
        let newStatus = "\(ingredient)/\(maxCapacity) " + measurementUnit
        print(warningString, (name.capitalized), ": ", oldStatus, " -> ", newStatus, separator: "", terminator: "\n")
    }
    
    private func clean() {
        cupsMade = 0
        print("Cleaning completed! Now you can make up to \(cupsBeforeClean) cups.")
    }
    
    private func hasEnoughIngredients(for drink: CoffeeDrink, quantity: Int) -> Bool {
        return ingredients.water >= drink.water * quantity && ingredients.coffee >= drink.coffee * quantity && ingredients.milk >= drink.milk * quantity
    }
    
    private func make(drink: CoffeeDrink, quantity: Int) {
        guard !needsCleaning else {
            print("--Please clean the coffemachine first.")
            return
        }
        guard quantity <= cupsBeforeClean - cupsMade else {
            print("--Only \(cupsBeforeClean - cupsMade) cups can be made.")
            if cupsMade != 0 {
                print("--Please clean the coffemachine first to make up to \(cupsBeforeClean) cups.")
            }
            return
        }
        guard hasEnoughIngredients(for: drink, quantity: quantity) else {
            print("--Not enough ingredients to make \(quantity) \(drink.name).")
            print(ingredientsStatus)
            return
        }
        ingredients.water -= drink.water * quantity
        ingredients.coffee -= drink.coffee * quantity
        ingredients.milk -= drink.milk * quantity
        cupsMade += quantity
        let be = quantity == 1 ? "is" : "are"
        let quantityString = quantity == 1 ? "" : String(quantity)
        print("Your", quantityString, drink.name, be, "ready!")
        print(ingredientsStatus)
        print(cleaningStatus)
    }
    
    private func printRecipe(of drink: CoffeeDrink) {
        print("~\(drink.name.capitalized)~")
        print("Water: \(drink.water) ml, coffee: \(drink.coffee) g, milk: \(drink.milk) ml")
    }
    
    private func printUsage() {
        let title = "==Coffeemachine usage=="
        let args = "Use full or short arguments names: w == water, c == coffee, m == milk; es == espresso, ca == cappucchino, la == latte"
        let on = "on - To turn on"
        let off = "off - To turn off"
        let add = "add 'ingredient name' 'quantity' - To add ingredients (run without 'quantity' to fill completely). Example: add c 200"
        let check = "check 'ingredient name' - To check ingredient amount (run without arguments to check all ingredients and cleaning status). Example: check w"
        let clean = "clean - To clean the coffeemachine"
        let make = "make 'coffee drink' 'cups' - To make a drink (espresso, cappuchino, latte). Without cups quantity one cup will be made. Example: make latte 2"
        let makeCustom = "make 'coffee amount' 'water amount' 'milk amount' - To make custom coffee drink. Example: make 15 60 100"
        let printRecipe = "recipe 'coffee drink' - To print a recipe of a drink. Example: print ca"
        let help = "help - To view manual"
        let quit = "quit - To quit the program"
        let all = [title, args, on, off, add, check, clean, make, makeCustom, printRecipe, help, quit].joined(separator: "\n")
        print(all)
    }
    
    // MARK: - Public API
    
    func handleInput() {
        var shouldQuit = false
        input: while !shouldQuit {
            let input = getInput()
            let args = input.components(separatedBy: " ")
            guard !args.isEmpty else { continue input }
            let commandString = args[0]
            guard let command = Command(rawValue: commandString) else { print("--Incorrect command. Run 'help' to view manual"); continue input }
            switch command {
            case .on:
                guard args.count == 1 else { print("--Incorrect input"); continue input }
                guard !isOn else { print("--Coffeemechine is already on"); continue input }
                turnOn()
            case .off:
                guard args.count == 1 else { print("--Incorrect input"); continue input }
                guard isOn else { print("--Coffeemechine is already off"); continue input }
                turnOff()
            case .add:
                guard isOn else { print("--Coffeemechine is off. Run 'on' to turn on"); continue input }
                guard args.count >= 2 else { print("--Incorrect input"); continue input }
                let ingredientString = args[1]
                let prefix = String(ingredientString.prefix(1))
                guard let ingredient = Argument(rawValue: prefix) else { print("--Incorrect ingredient"); continue input }
                var amount: Int
                switch args.count {
                case 2: amount = Int.max
                case 3:
                    let amountString = args[2]
                    guard let amountInt = Int(amountString), amountInt > 0 else { print("--Incorrect amount"); continue input }
                    amount = amountInt
                default:
                    print("--Incorrect arguments count")
                    continue input
                }
                switch ingredient {
                case .water:
                    add(&ingredients.water, amount: amount, maxCapacity: waterCapacity, name: "Water", measurementUnit: "ml")
                case .milk:
                    add(&ingredients.milk, amount: amount, maxCapacity: milkCapacity, name: "Milk", measurementUnit: "ml")
                case .coffee:
                    add(&ingredients.coffee, amount: amount, maxCapacity: coffeeCapacity, name: "Coffee", measurementUnit: "g")
                default:
                    print("--Incorrect ingredient")
                }
            case .check:
                guard isOn else { print("--Coffeemechine is off. Run 'on' to turn on"); continue input }
                switch args.count {
                case 1:
                    print(ingredientsStatus)
                    print(cleaningStatus)
                case 2:
                    let argumentString = args[1]
                    let prefix = String(argumentString.prefix(1))
                    guard let argument = Argument(rawValue: prefix) else { print("--Incorrect argument"); continue input }
                    switch argument {
                    case .water:
                        print(waterStatus)
                    case .milk:
                        print(milkStatus)
                    case .coffee:
                        print(coffeeStatus)
                    default:
                        print("--Incorrect argument")
                    }
                default:
                    print("--Incorrect arguments count")
                }
            case .clean:
                guard isOn else { print("--Coffeemechine is off. Run 'on' to turn on"); continue input }
                clean()
            case .make:
                guard isOn else { print("--Coffeemechine is off. Run 'on' to turn on"); continue input }
                switch args.count {
                case 2, 3:
                    let drinkString = args[1]
                    let prefix = String(drinkString.prefix(2))
                    guard let drink = Argument(rawValue: prefix) else { print("--Incorrect drink name"); continue input }
                    var quantity = 1
                    if args.count == 3 {
                        let cupsNumberString = args[2]
                        guard let cupsNumber = Int(cupsNumberString), cupsNumber > 0 else { print("--Incorrect cups number"); continue input }
                        quantity = cupsNumber
                    }
                    switch drink {
                    case .espresso:
                        make(drink: Espresso(), quantity: quantity)
                    case .cappuchino:
                        make(drink: Cappuchino(), quantity: quantity)
                    case .latte:
                        make(drink: Latte(), quantity: quantity)
                    default:
                        print("--Incorrect drink name")
                    }
                case 4:
                    let amounts = args.suffix(3).compactMap({Int($0)}).filter({$0 > 0})
                    guard amounts.count == 3 else { print("--Incorrect input"); continue input }
                    let coffeeAmount = amounts[0]
                    let waterAmount = amounts[1]
                    let milkAmount = amounts[2]
                    let drink = CustomDrink(name: "drink", water: waterAmount, coffee: coffeeAmount, milk: milkAmount)
                    make(drink: drink, quantity: 1)
                default: print("--Incorrect input")
                }
            case .recipe:
                guard isOn else { print("--Coffeemechine is off. Run 'on' to turn on"); continue input }
                guard args.count == 2 else { print("--Incorrect input"); continue input }
                let drinkString = args[1]
                let prefix = String(drinkString.prefix(2))
                guard let drink = Argument(rawValue: prefix) else { print("--Incorrect drink name"); continue input }
                switch drink {
                case .espresso:
                    printRecipe(of: Espresso())
                case .cappuchino:
                    printRecipe(of: Cappuchino())
                case .latte:
                    printRecipe(of: Latte())
                default:
                    print("--Incorrect drink name")
                    continue input
                }
            case .help:
                printUsage()
            case .quit:
                shouldQuit = true
            }
        }
    }
}

let coffeeMachine = CoffeeMachine()
print("Run 'help' to view manual")
coffeeMachine.handleInput()


//
//  ContentView.swift
//  reactionTime
//
//  Created by Hedi Zitouni on 11/07/2021.
//

import SwiftUI

struct ContentView: View {
    
    @State private var worstReactionTime: Double;
    @State private var bestReactionTime: Double;
    @State private var averageTime: Double;
    @State private var nbFail: Int;
    @State private var nbSuccess: Int;
    
    @State private var reactionTime: Double
    @State private var currentTime: Double = 0;
    @State private var isTimerOn: Bool = false;
    @State private var isSleeping: Bool = false;
    private let precision: Double = 1000;
    
    private let softGrey: Color = Color(red: 0.35, green: 0.35, blue: 0.35, opacity: 1.0);
    private let mediumGrey: Color = Color(red: 0.25, green: 0.25, blue: 0.25, opacity: 1.0);
    private let sleepingColor: Color = .red;
    private let reactionColor: Color = .green;
    
    @State private var arrayColors : Array<Color>;
    
    @State private var labelButton: String = "START";
    
    @State private var idGame: Int = 1;
    let defaults = UserDefaults.standard;
    
    
    func startTimer(_ currentIdGame: Int) {
        if (currentIdGame == idGame) {
            currentTime = NSDate().timeIntervalSince1970;
            isTimerOn = true;
            isSleeping = false;
            arrayColors = [reactionColor]
            labelButton = "CLICK"
        }
    }

    init() {
        bestReactionTime = defaults.double(forKey: "bestReactionTime") == 0.0 ? Double.greatestFiniteMagnitude : defaults.double(forKey: "bestReactionTime")
        worstReactionTime = defaults.double(forKey: "worstReactionTime") == 0.0 ? 0.0 : defaults.double(forKey: "worstReactionTime")
        
        arrayColors  = [Color(red: 0.35, green: 0.35, blue: 0.35, opacity: 1.0),
                        Color(red: 0.25, green: 0.25, blue: 0.25, opacity: 1.0),
                        Color(red: 0.35, green: 0.35, blue: 0.35, opacity: 1.0)];
        reactionTime = Double.greatestFiniteMagnitude;
        averageTime = defaults.double(forKey: "averageTime") == 0.0 ? Double.greatestFiniteMagnitude : defaults.double(forKey: "averageTime")
        nbFail = defaults.integer(forKey: "nbFail")
        nbSuccess = defaults.integer(forKey: "nbSuccess")
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: arrayColors), startPoint: .topTrailing, endPoint: .bottomLeading)
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                
                HStack(spacing: 0.0) {
                    if (bestReactionTime != Double.greatestFiniteMagnitude) {
                        Text("BEST: ")
                        Text(String(bestReactionTime))
                            .font(.title)
                            .fontWeight(.black)
                        Text("ms")
                            .font(.title)
                    }
                }.padding(.top, 50.0)
                HStack(spacing: 0.0) {
                    if (worstReactionTime != 0.0) {
                        Text("WORST: ")
                        Text(String(worstReactionTime))
                            .font(.title)
                            .fontWeight(.black)
                        Text("ms")
                            .font(.title)
                    }
                }
                
                Spacer()

                HStack(spacing: 1.0) {
                    if (reactionTime != Double.greatestFiniteMagnitude) {
                        Text(String(reactionTime))
                            .font(.title2)
                            .fontWeight(.black)
                        Text("ms")
                            .font(.title2)
                    }
                }
                Spacer()
                VStack {
                    HStack(spacing: 0.0) {
                        if (averageTime != Double.greatestFiniteMagnitude) {
                            Text("AVERAGE: ")
                            Text(String(round(averageTime)))
                                .font(.title)
                                .fontWeight(.black)
                            Text("ms")
                                .font(.title)
                        }
                    }
                    HStack(spacing: 0.0) {
                        Text("SUCCESS: ")
                        Text(String(nbSuccess))
                            .font(.title)
                            .fontWeight(.black)
                    }
                    HStack(spacing: 0.0) {
                        Text("FAILS: ")
                        Text(String(nbFail))
                            .font(.title)
                            .fontWeight(.black)
                    }
                }
                Spacer()
            }
            
            VStack {
            
                Button(action: {
                    
                    if (!isTimerOn && !isSleeping) {
                        // User clicked on START
                        
                        let delay = Double.random(in: 2...10)
                        arrayColors = [sleepingColor]
                        labelButton = "GET READY"
                        isSleeping = true;
                        let currentIdGame = idGame;
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            startTimer(currentIdGame);
                        }

                    } else if(isSleeping) {
                        // The user clicked too early after START
                        
                        arrayColors = [softGrey, mediumGrey, softGrey]
                        labelButton = "TOO EARLY TRY AGAIN"
                        isTimerOn = false;
                        isSleeping = false;
                        idGame = idGame + 1;
                        nbFail += 1
                        defaults.set(nbFail, forKey: "nbFail");
                    } else if(!isSleeping){
                        // The user clicked well during Green screen
                        reactionTime = round((NSDate().timeIntervalSince1970 - currentTime) * precision);
                        
                        averageTime = averageTime == Double.greatestFiniteMagnitude ? reactionTime : (averageTime * Double(nbSuccess) + reactionTime) / Double(nbSuccess + 1)
                        defaults.set(averageTime, forKey: "averageTime");
                        nbSuccess += 1
                        defaults.set(nbSuccess, forKey: "nbSuccess");
                        arrayColors = [softGrey, mediumGrey, softGrey]
                        labelButton = "START"
                        isTimerOn = false;
                        if (reactionTime < bestReactionTime) {
                            bestReactionTime = reactionTime;

                            defaults.set(bestReactionTime, forKey: "bestReactionTime");

                        }
                        if (reactionTime > worstReactionTime) {
                            worstReactionTime = reactionTime;

                            defaults.set(worstReactionTime, forKey: "worstReactionTime");

                        }
                        
                        idGame = idGame + 1;
                        
                    }

                    
                }, label: {
                    Text(labelButton)
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundColor(Color.black)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 100)
                })
                
                Button(action: {
                    averageTime = Double.greatestFiniteMagnitude;
                    defaults.set(averageTime, forKey: "averageTime");
                    
                    bestReactionTime = Double.greatestFiniteMagnitude;
                    defaults.set(bestReactionTime, forKey: "bestReactionTime");
                    
                    worstReactionTime = 0.0;
                    defaults.set(worstReactionTime, forKey: "worstReactionTime");
                    
                    nbFail = 0;
                    defaults.set(nbFail, forKey: "nbFail");
                    
                    nbSuccess = 0;
                    defaults.set(nbSuccess, forKey: "nbSuccess");
                    
                }, label: {
                    Text("Reset")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundColor(Color.black)
                        .frame(width: UIScreen.main.bounds.width, height: 100)
                        .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.gray/*@END_MENU_TOKEN@*/)
                })
            }
            
            
        }
        .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewDevice("iPad (8th generation)")
        }
    }
}

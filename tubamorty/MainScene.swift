//
//  MainScene.swift
//  tubamorty
//
//  Created by Jonas Treumer on 18.01.17.
//  Copyright © 2017 TU Bergakademie Freiberg. All rights reserved.
//

import SpriteKit

class MainScene: SKScene
{
    //Have we already done the initialization?
    private var isInitialized = false
    
    //The current time:
    private var currentTime: TimeInterval = 0
    
    //All the targets that are currently around:
    private var targets = [SwipeTarget]()
    
    //The cut line:
    private let cutLine = CutLine()
    
    //The background:
    private let background = SKSpriteNode(imageNamed: "Background")
    
    //The label for Lost, Won etc.:
    private let label = SKLabelNode(fontNamed: "Chalkduster")
    
    //In which wave are we currently?
    private var waveCounter = 0
    
    //How many lifes do we have left?
    private var lifeCounter = 3
    
    //Did we blow up?
    //That's a safe death, no chance to collect some lifes on the fly:
    private var blownUp = false
    
    //Is the game currently running?
    private var gamePaused = false
    
    private class func selectRandomImage(fromImages images: [UIImage]) -> UIImage
    {
        return images[Int(arc4random_uniform(UInt32(images.count)))]
    }
    
    override init()
    {
        super.init()
        commonInit()
    }
    
    override init(size: CGSize)
    {
        super.init(size: size)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit()
    {
        guard !self.isInitialized else
        {
            return
        }
        
        //Add background:
        self.background.position = CGPoint(x: 0, y: 0)
        self.addChild(self.background)
        
        //Add label:
        self.label.position = CGPoint(x: 0, y: 0)
        self.label.fontSize = 65
        self.label.isHidden = true
        
        self.addChild(self.label)
        
        //Add cutline:
        self.cutLine.strokeColor = SKColor(red: 0.85, green: 0, blue: 0, alpha: 0.3)
        self.cutLine.lineWidth = 20
        self.cutLine.lineCap = .round
        
        self.addChild(self.cutLine)
        
        //We are done:
        self.isInitialized = true
    }
    
    private func processHits(atPoints points: [CGPoint])
    {
        //Process the points:
        for point in points
        {
            //Try to hit:
            self.targets.forEach({ $0.tryHit(withPoint: point) })
        }
    }
    
    override func didMove(to view: SKView)
    {
        //Set size and scale mode:
        self.size = view.bounds.size
        self.scaleMode = .aspectFill
        
        //Fix anchor point at center:
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //Set background size:
        self.background.size = self.size
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        //Superclass:
        super.update(currentTime)
        
        //Save the current time:
        self.currentTime = currentTime
        
        //Draw the cut line:
        self.cutLine.drawPath()
        
        //Are we paused?
        guard !self.gamePaused else
        {
            return
        }
        
        //Are we done with the wave?
        if self.targets.count == 0
        {
            //Spawn the next one:
            self.waveCounter += 1
            self.targets = spawnWave()
            
            //Add the targets:
            self.targets.forEach({ self.addChild($0) })
            
            //Did we win?
            if self.targets.count == 0
            {
                self.gamePaused = true
                gameWon()
                
                return
            }
        }
        
        //Did we lose all lives or blow up?
        if (self.lifeCounter == 0) || self.blownUp
        {
            self.targets.forEach({ $0.removeFromParent() })
            self.targets.removeAll()
            self.gamePaused = true
            gameLost(byBlowUp: self.blownUp)
            
            return
        }
        
        //Update all the targets:
        self.targets = self.targets.filter()
        {
            //Update the target:
            switch $0.update(currentTime, withSceneSize: self.size)
            {
            case .survived:
                
                //Remove the target from the scene and invoke the callback:
                $0.removeFromParent()
                targetSurvived($0)
                
                //Reduce the life:
                self.lifeCounter = max(0, self.lifeCounter - $0.lifesLostOnSurvival)
                
                //Remove from array:
                return false
                
            case .killed:
                
                //Remove the target from the scene and invoke the callback:
                $0.removeFromParent()
                targetKilled($0)
                
                //Remove from array:
                return false
                
            default:
                
                //Keep the target:
                return true
            }
        }
    }
    
    //Manage cuts:
    func beginCut(withTouch touch: UITouch)
    {
        processHits(atPoints: self.cutLine.beginCut(withPoint: touch.location(in: self)))
    }
    
    func proceedCut(withTouch touch: UITouch)
    {
        processHits(atPoints: self.cutLine.proceedCut(withPoint: touch.location(in: self)))
    }
    
    func endCut(withTouch touch: UITouch)
    {
        self.cutLine.endCut()
        
        //Cancel the hits:
        self.targets.forEach({ $0.cancelHit() })
    }
    
    
    
    
    //*******************
    //*** Start here! ***
    //*******************
    
    //TODO: Manage the waves.
    func spawnWave() -> [SwipeTarget]
    {
        //Switch over self.waveCounter. It starts with 1.
        switch self.waveCounter
        {
        default:
            
            return []
        }
    }
    
    //TODO: A swipe target has survived.
    func targetSurvived(_ swipeTarget: SwipeTarget)
    {
        //swipeTarget.lifesLostOnSurvival determines the number of lifes that will be lost.
        //It is subtracted after this call.
    }
    
    //TODO: A swipe target has been killed.
    func targetKilled(_ swipeTarget: SwipeTarget)
    {
        //Grant some points to the player.
        //Or blow him/her up by setting self.blownUp.
    }
    
    //TODO: We won the game.
    func gameWon()
    {
        self.label.isHidden = false
        self.label.text = "You won!"
        self.label.fontColor = SKColor.green
    }
    
    //TODO: We lost the game.
    func gameLost(byBlowUp blowUp: Bool)
    {
        self.label.isHidden = false
        self.label.text = "Game over"
        self.label.fontColor = SKColor.red
    }
}

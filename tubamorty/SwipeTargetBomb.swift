//
//  SwipeTargetBomb.swift
//  tubamorty
//
//  Created by Jonas Treumer on 27.01.17.
//  Copyright © 2017 TU Bergakademie Freiberg. All rights reserved.
//

import SpriteKit

class SwipeTargetBomb: SwipeTargetRandomized
{
    static let linclerImage = UIImage(named: "Lincler")!
    
    override func didLaunch() -> SKPhysicsBody
    {
        let physics = super.didLaunch()
        
        physics.categoryBitMask = PhysicsCategory.Special
        physics.collisionBitMask = PhysicsCategory.Wall | PhysicsCategory.Normal
        
        return physics
    }
    
    override func handleKill() -> [SwipeTargetAction]
    {
        return [.blowUp]
    }
}

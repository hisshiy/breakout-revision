
//  Created by x13101xx on 2015/06/10.
//  Copyright (c) 2015年 Tomohisa HISHINUMA. All rights reserved.
//
import UIKit
import SpriteKit

class CLEAR: SKScene {
    
    override func didMoveToView(view: SKView) {
        //背景色
        self.backgroundColor = UIColor.blackColor()
        //タイトル表示
        let title = SKLabelNode(fontNamed: "block")
        title.text = "GAME CLEAR";
        title.fontSize = 60;
        title.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        self.addChild(title)
        
        //Start表示
        let startLabel = SKLabelNode(fontNamed: "title")
        startLabel.text = "タイトルへ"
        startLabel.fontSize = 60
        startLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)-200)
        startLabel.name = "Start"
        self.addChild(startLabel)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touches : AnyObject in touches{
            
            // タッチした点を得る.
            let location = touches.locationInNode(self)
            let touchedNode = self.nodeAtPoint(location)
            
            if (touchedNode.name != nil){
                if touchedNode.name == "Start"{
                    let newScene = TitleScene(size: self.scene!.size)
                    newScene.scaleMode = SKSceneScaleMode.AspectFill
                    self.view!.presentScene(newScene)
                }
                
            }
            
        }
    }
    
    override func update(currentTime: CFTimeInterval){}
    
    
    
    
    
    
}
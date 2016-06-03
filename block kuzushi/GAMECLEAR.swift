//
import UIKit
import SpriteKit

class GAME_CLEAR: SKScene {
    
    override func didMoveToView(view: SKView) {
        //タイトル表示
        let title = SKLabelNode(fontNamed: "block")
        title.text = "ブロック崩し";
        title.fontSize = 60;
        title.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        self.addChild(title)
        
        //Start表示
        let startLabel = SKLabelNode(fontNamed: "title")
        startLabel.text = "Start"
        startLabel.fontSize = 60
        startLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)-200)
        startLabel.name = "Start"
        self.addChild(startLabel)
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touches : AnyObject in touches{
            
            // タッチした点を得る.
            let location = touches.locationInNode(self)
            let touchedNode = self.nodeAtPoint(location)
            
            if (touchedNode.name != nil){
                if touchedNode.name == "Start"{
                    let newScene = GameScene(size: self.scene!.size)
                    newScene.scaleMode = SKSceneScaleMode.AspectFill
                    self.view!.presentScene(newScene)
                }
                
            }
            
        }
    }
    
    override func update(currentTime: CFTimeInterval){}
    
    
    
    
    
    
}
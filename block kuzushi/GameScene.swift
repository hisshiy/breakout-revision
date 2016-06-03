//
//  GameScene.swift
//  block kuzushi
//
//  Created by x13101xx on 2015/06/07.
//  Copyright (c) 2015年 Tomohisa HISHINUMA. All rights reserved.
//
import UIKit
import SpriteKit

extension SKScene{
    
    /*
    Sceneの中央値を返すメソッド.
    */
    func GetMidPoint()->CGPoint{
        return CGPointMake(self.frame.midX, self.frame.midY)
    }
    
}

var ballLife:UInt!
var score:UInt!

class GameScene: SKScene,SKPhysicsContactDelegate{
    
    
    //private：同じソースコードからしかアクセスできない

    //円
    private var circle : SKShapeNode!
    //動き
    private var FollowRectMoveAction : SKAction!
    //四角
    private var rect : SKShapeNode!
    //ブロック
    private var block : SKSpriteNode!
    let margin:CGFloat = 1
    //ボール
    private var ball : SKShapeNode!
    private var bx:CGFloat!
    private var by:CGFloat!
    let en:CGFloat = 10
    //バー
    private var bar:SKSpriteNode!
    private var x:CGFloat!
    private var y:CGFloat!
    //画面外
    private var deadzone : SKSpriteNode!
    //ループ用
    var loop:Bool = false,reboneflag:Bool = false,deadflag:Bool = false
    //ブロック
    let block_row:Int = 10,block_col:Int = 8//数:横、縦
    let block_width:CGFloat = 30,block_height:CGFloat = 20//大きさ
    var block_x:CGFloat!,block_y:CGFloat!//座標
    
    var count:Int = 0
    var life:Int = 0
    //表示用
    var showString:SKLabelNode!
    //スコア
    var score_mag:Int!
    
    //CollistonMask
    let blockCategory: UInt32 = 1 << 0
    let ballCategory:  UInt32 = 1 << 1
    let wallCategory:  UInt32 = 1 << 2
    let barCategory:UInt32 = 1 << 3
    let deadCategory:  UInt32 = 1 << 4
    
    
    
    override init(size: CGSize) {
        super.init(size: size)
        
        //背景色
        self.backgroundColor = UIColor.blackColor()
        //ループ用
        loop = false
        reboneflag = false
        deadflag = false
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect:self.frame)
        //ボールが浮遊
        self.physicsWorld.gravity = CGVectorMake( 0.0, 0.0 )
        //衝突をさけるため、強制的にselfをセット
        self.physicsWorld.contactDelegate = self
        //設定した物体とだけ衝突したときに衝突判定のメソッドが呼ばれる
        self.physicsBody?.collisionBitMask = wallCategory
        
        //スコア、残機
        score = 0
        score_mag = 0
        ballLife = 4
        life = 3
        showString = SKLabelNode()
        showString.text = ("残機:\(life)")
        showString.position = CGPointMake(self.size.width/2, self.size.height-showString.frame.height-20)
        
        
        
        
        //画面外
        deadzone = SKSpriteNode()
        deadzone.position = CGPointMake(self.size.width/2, 0)
        //SKPhysicsBodyを使用することで物理シミレーションの対象に
        deadzone.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.size.width, self.size.height-730))
        //物体が接触しても動かないようにする
        deadzone.physicsBody?.dynamic = false
        //自身がどの物体と接触した場合に衝突させるかを判定する
        deadzone.physicsBody?.collisionBitMask = deadCategory
        //ここで設定した物体(ボール)とだけ衝突したときに衝突判定のメソッドが呼ばれる
        deadzone.physicsBody?.contactTestBitMask = ballCategory
        
        //ブロック配置
        for (var i:Int = 1; i <= 5; i++){
            for (var j:Int = 1; j <= 3; j++){
                //四角形の作成
                 let block = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(50, 20))
                //ブロックの場所
                //x座標：ループの回数×画面の横サイズ/ブロックの横の総数
                //y座標：画面の縦サイズ−ループの回数×２×ブロックの高さ
                let block_position = CGPointMake(270+CGFloat(i)*(self.size.width/CGFloat(block_row)-20), self.size.height-CGFloat(j)*2*(block_height+margin)-50)
                //ブロックの名前
                //block.name = "block"
                //ブロックを決めた場所に移動
                block.position = block_position
                //SKPhysicsBodyを使用することで物理シミレーションの対象に
                block.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(block_width, block_height))
                //NSMutableDictionary:オブジェクトの集合を格納するもの
                //ブロックのライフをランダムで与える
                //内容が変更できる辞書 ( NSMutableDictionary )
                //arc4random:０から２までの値＋１の値をランダムで取得する（arc4randomは初期化、生成を同時に行ってくれる）
                block.userData = NSMutableDictionary(dictionary: ["life":Int(arc4random()%2+1)])
                //ここでブロックそれぞれにライフを持たせ、グラデーションをかける
                block.alpha *= block.userData?.valueForKey("life") as! CGFloat / 5
                //物体が接触しても動かないようにする
                block.physicsBody?.dynamic = false
                //自身がどの物体と接触した場合に衝突させるかを判定する
                block.physicsBody?.collisionBitMask = blockCategory
                //ここで設定した物体(ボール)とだけ衝突したときに衝突判定のメソッドが呼ばれる
                block.physicsBody?.contactTestBitMask = ballCategory
                //ブロックの配置
                self.addChild(block)
            }
        }
        
        //バー配置
        //バーのx座標　バーのy座標
        x = CGRectGetMidX(self.frame);y = CGRectGetMidY(self.frame) - 300
        //バーの色、大きさ
        bar = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(100, 20))
        //バーの場所
        bar.position = CGPointMake(x, y)
        //SKPhysicsBodyを使用することで物理シミレーションの対象に
        bar.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(100, 20))
        //物体が接触しても動かないようにする
        bar.physicsBody?.dynamic = false
        //自身がどの物体と接触した場合に衝突させるかを判定する
        bar.physicsBody?.collisionBitMask = barCategory
        
        //ボール配置
        //ボールのx座標 ボールのy座標
        bx = x;
        by = y+100
        //ボールの色、サイズ
        ball = SKShapeNode(circleOfRadius: en)
        ball.fillColor = UIColor.yellowColor()
        //ボールを作り出す位置
        ball.position = CGPointMake(bx, by)
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: en)
        //SKPhysicsBodyを使用することで物理シミレーションの対象に
        //ball.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(20, 20))
        ////自身がどの物体と接触した場合に衝突させるかを判定する
        ball.physicsBody?.collisionBitMask = ballCategory
        //ここで設定した物体(バー、ブロック、画面外)とだけ衝突したときに衝突判定のメソッドが呼ばれる
        ball.physicsBody?.contactTestBitMask = barCategory|blockCategory|deadCategory
        //物体（ボール）を回転させるか否か
        ball.physicsBody?.allowsRotation = false
        //反発力
        ball.physicsBody?.restitution = 1
        //摩擦係数
        ball.physicsBody?.friction = 0
        //空気抵抗
        ball.physicsBody?.linearDamping = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
        /**画面が表示された時に実行される**/
    override func didMoveToView(view: SKView) {

        let abc = SKShapeNode(rectOfSize: CGSizeMake(445, 800.0))
        // 線の太さを2.0に指定.
        abc.lineWidth = 2.0
        // 四角形の枠組みの剛体を作る.
        abc.physicsBody = SKPhysicsBody(edgeLoopFromRect: abc.frame)
        abc.position = CGPointMake(self.frame.midX, self.frame.midY)
        self.addChild(abc)
        
        //スコア表示
          self.addChild(showString)
        // 画面外の配置
          self.addChild(deadzone)
        //バーの配置
          self.addChild(bar)
        //ボールの配置
          self.addChild(ball)
        //エッジを作ってノードが画面からはみ出さないように
            self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
    }

    
    //画面をタッチしたときに実行される
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
            if(!loop){
                bollidou()
            }
        if(loop){
            for touch : AnyObject in touches{
                let location = touch.locationInNode(self)
                bar.position.x = location.x
            }
        }
    }
    //ドラッグイベント
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(loop){
            for touch : AnyObject in touches{
                    let location = touch.locationInNode(self)
                    bar.position.x = location.x
            }
        }
    }

    //ボールの軌道
    func bollidou(){
        loop = true
        let randam = CGFloat(arc4random()%100)
        //dx,dyの方向へランダムへ力を加える
        let ballVel = CGVector(dx:((arc4random()%2==0) ? -200-randam:200+randam), dy:200+randam)
        //力を加える　実行
        ball.physicsBody?.velocity = ballVel
        
    }
    
    func accelerate() {
        //力を加える　実行
        ball.physicsBody?.velocity.dx *= 1.05
        ball.physicsBody?.velocity.dy *= 1.05
    }
    
    func rebone(){
        reboneflag = false
        //残機を減らす
        ballLife = ballLife - 1
        life = life - 1
        if(life == 0){
            let newScene = OVER(size: self.scene!.size)
            newScene.scaleMode = SKSceneScaleMode.AspectFill
            self.view!.presentScene(newScene)
        }
        //ループ終了
        loop = false
        //力を加える
        ball.physicsBody?.velocity = CGVector(dx:0,dy:0)
        //バーの場所を元に戻す
        bar.position = CGPointMake(x,y)
        //ボールの場所を元に戻す
        ball.position = CGPointMake(bx, by)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var first,second : SKPhysicsBody
        //categoryBitMask:自分のカテゴリを表す
        if(contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
            first = contact.bodyA
            second = contact.bodyB
        }else{
            first = contact.bodyB
            second = contact.bodyA
        }
        //collisionBitMask:衝突の相手となるカテゴリを示す値を設定
        if(first.collisionBitMask == ballCategory){
            switch second.collisionBitMask{
                //ブロックに当たった場合
            case blockCategory:
                accelerate()
                //ライフを減らす（ブロックを消す）
                var life :Int = (second.node?.userData?.valueForKey("life") as! Int)
                life--
                second.node?.userData?.setObject(life, forKey: "life")
                second.node?.alpha *= 0.5
                if((second.node?.userData?.valueForKey("life") as! Int) < 1){
                    //削除する
                    second.node?.removeFromParent()
                    count++
                }
                if(count == 15){
                    let newScene = CLEAR(size: self.scene!.size)
                    newScene.scaleMode = SKSceneScaleMode.AspectFill
                    self.view!.presentScene(newScene)
                }
                //画面外
            case deadCategory :
                if(ballLife > 1){
                    reboneflag = true
                }else{
                    deadflag = true
                }
                //バー
            case barCategory:
                score_mag = 0
            default:
                break
            }
            
        }
        
    }
    
    //フレームごとに実行
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        showString.text = ("残機:\(life)")
        if(reboneflag){
            rebone()
        }
    }


}

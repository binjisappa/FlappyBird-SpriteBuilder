//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Benjamin Encz on 10/10/13.
//  Copyright (c) 2014 MakeGamesWithUs inc. Free to use for all purposes.
//

#import "MainScene.h"
#import "Obstacle.h"

@implementation MainScene {
    CCNode *_ground1;
    CCNode *_ground2;
    NSArray *_grounds;
    
    CCNode *_cloud1;
    CCNode *_cloud2;
    NSArray *_clouds;
    
    CCNode *_bush1;
    CCNode *_bush2;
    NSArray *_bushes;
    
    
    NSTimeInterval _sinceTouch;
    
    NSMutableArray *_obstacles;
    
    CCButton *_restartButton;
    
    BOOL _gameOver;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_nameLabel;
    
    int points;
}


- (void)didLoadFromCCB {
    self.userInteractionEnabled = TRUE;
    
    _grounds = @[_ground1, _ground2];
    _clouds = @[_cloud1, _cloud2];
    _bushes = @[_bush1, _bush2];
    
    for (CCNode *ground in _grounds) {
        // set collision txpe
        ground.physicsBody.collisionType = @"level";
        ground.zOrder = DrawingOrderGround;
    }
    
    // set this class as delegate
    physicsNode.collisionDelegate = self;
    
    _obstacles = [NSMutableArray array];
    points = 0;
    _scoreLabel.visible = true;
    
    [super initialize];
}

#pragma mark - Touch Handling

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!_gameOver) {
        [character.physicsBody applyAngularImpulse:10000.f];
        _sinceTouch = 0.f;
        
        @try
        {
            [super touchBegan:touch withEvent:event];
        }
        @catch(NSException* ex)
        {
            
        }
    }
}

#pragma mark - Game Actions

- (void)gameOver {
    if (!_gameOver) {
        _gameOver = TRUE;
        _restartButton.visible = TRUE;
        
        character.physicsBody.velocity = ccp(0.0f, character.physicsBody.velocity.y);
        character.rotation = 90.f;
        character.physicsBody.allowsRotation = FALSE;
        [character stopAllActions];
        
        CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.2f position:ccp(-2, 2)];
        CCActionInterval *reverseMovement = [moveBy reverse];
        CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
        CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
        
        [self runAction:bounce];
    }
}

- (void)restart {
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

#pragma mark - Obstacle Spawning

- (void)addObstacle {
    Obstacle *obstacle = (Obstacle *)[CCBReader load:@"Obstacle"];
    CGPoint screenPosition = [self convertToWorldSpace:ccp(380, 0)];
    CGPoint worldPosition = [physicsNode convertToNodeSpace:screenPosition];
    obstacle.position = worldPosition;
    [obstacle setupRandomPosition];
    obstacle.zOrder = DrawingOrderPipes;
    [physicsNode addChild:obstacle];
    [_obstacles addObject:obstacle];
}

#pragma mark - Update

- (void)showScore
{
    _scoreLabel.string = [NSString stringWithFormat:@"%d", points];
    _scoreLabel.visible = true;
}

- (void)update:(CCTime)delta
{
    _sinceTouch += delta;
    
    character.rotation = clampf(character.rotation, -30.f, 90.f);
   
    NSMutableArray *offScreenObstacles = nil;
    
    for (CCNode *obstacle in _obstacles) {
        CGPoint obstacleWorldPosition = [physicsNode convertToWorldSpace:obstacle.position];
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
        if (obstacleScreenPosition.x < -obstacle.contentSize.width) {
            if (!offScreenObstacles) {
                offScreenObstacles = [NSMutableArray array];
            }
            [offScreenObstacles addObject:obstacle];
        }
    }
    
    for (CCNode *obstacleToRemove in offScreenObstacles) {
        [obstacleToRemove removeFromParent];
        [_obstacles removeObject:obstacleToRemove];
    }
    
    if (!_gameOver)
    {
        @try
        {
            character.physicsBody.velocity = ccp(80.f, clampf(character.physicsBody.velocity.y, -MAXFLOAT, 200.f));
            
            [super update:delta];
        }
        @catch(NSException* ex)
        {
            
        }}
    
   }

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair*)pair character:(CCSprite*)character level:(CCNode*)level {
    [self gameOver];
    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)character goal:(CCNode *)goal {
    [goal removeFromParent];
    points++;
    _scoreLabel.string = [NSString stringWithFormat:@"%d", points];
    return TRUE;
}

@end

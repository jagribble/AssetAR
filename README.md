#  AssetAR
AssetAR is an asset managment app using AR enabling engineers to easiy find and diagnos assets out in the field


### Rendering Assets
Assets are rendered acording to their relation to the users GPS. When the app is first opned (or refreshed) their GPS co-ordinates are taken. These are used to workout where to render the asset in relation to the user

>**Note:** When ARKit is initalized the users positon is (0,0) and all assets are rendered in relation to that instead of  standard GPS co-ordinates. However the heading is set to true north with `configuration.worldAlignment = .gravityAndHeading` in the `viewWillAppear()` function

```Swift
let ballNodeX:Float
let ballNodeZ:Float
ballNodeX = ((asset1.assetLocationX)-(Float(locValue.latitude) ))//East/West
ballNodeZ = (Float(locValue.longitude)-(asset1.assetLocationZ))//North/South

print("ballNodeX = \(ballNodeX*10000),    ballNodeZ = \(ballNodeZ*10000)")
// If either (not both) values are negative keep same position otherwise take the negative positions (flip the axis)
// This takes into acccount the four quadrants
if((ballNodeZ < 0 && ballNodeX > 0) || (ballNodeX < 0 && ballNodeZ > 0)){
ballNode.position = SCNVector3Make(ballNodeX*10000,0, ballNodeZ*10000)
} else if((ballNodeZ > 0 && ballNodeX > 0) || (ballNodeZ < 0 && ballNodeX < 0)){
ballNode.position = SCNVector3Make(-ballNodeX*10000,0, -ballNodeZ*10000)
}
```


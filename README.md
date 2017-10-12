#  AssetAR
AssetAR is an asset managment app using AR enabling engineers to easiy find and diagnos assets out in the field


### Rendering Assets
Assets are rendered acording to their relation to the users GPS. When the app is first opned (or refreshed) their GPS co-ordinates are taken. These are used to workout where to render the asset in relation to the user

>**Note:** When ARKit is initalized the users positon is (0,0) and all assets are rendered in relation to that instead of  standard GPS co-ordinates. However the heading is set to true north with `configuration.worldAlignment = .gravityAndHeading` in the `viewWillAppear()` function

```Swift
let ballNodeX:Float
let ballNodeZ:Float
// if the users longitude value is less than the x value for the asset then take the current location from the assets else do it the other way
if(Float(locValue.longitude) < asset2.assetLocationX){
ballNodeX = ((asset2.assetLocationX)-(Float(locValue.longitude) ))//East/West
} else{
ballNodeX = (Float(locValue.longitude)-(asset2.assetLocationX))//East/West
}

// if the users longitude value is less than the z value for the asset then take the current location from the assets else do it the other way
if(Float(locValue.latitude) < asset2.assetLocationZ){
ballNodeZ = ( (asset2.assetLocationZ)-(Float(locValue.latitude) ))//North/South
} else{
ballNodeZ = (Float(locValue.latitude)-(asset2.assetLocationZ))//North/South
}
```


# CycloneLib

CycloneLib is a multipurpose library mod for [Risk of Rain Modloader](https://rainfusion.ml) holding range of utility functions.  
Most of the code has comments describing the functionality.  

## Includes

### Modules

Here is a list of modules:  
* collision: Some of the more strange collision functions such as finding the floor and raycasts.  
* font  
* list  
* misc  
* modloader  
* player  
* string  
* table: Functions such as swap, reverse and different types of copy/clone  
* net: Holds AutoPacket which handles the types passed to it automatically and executes it on every player

### Projectiles

A basic file that handles most of the common functionality of Projectiles  
Some notable issues:  
* High speed projectiles may pass through stuff (Not specific to this particular implementation).  
* Whether the projectile is dead or not should be checked (Since it doesn't spawn another instance for its death animation).  
* Since the create callback is triggered by Modloader some variables aren't fully available in that callback.  
If you think there is anything that could be improved, I would be glad to hear and most likely implement it.  
If you want to use it as stand-alone just copy `Projectile.lua` to your mods and require it:  
```
Projectile = require("Projectile")
```

### Classes

A basic class implementation and two classes.  
I would recommend using the `newtype` function found in Modloader if you would like to write your own classes.  
* Rectangle  
* Vector2  

## Contact

You can contact me through email `nonena@protonmail.com` or through the discord under the name `none#3549`.  
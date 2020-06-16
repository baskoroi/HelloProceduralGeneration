# Proxima C

By: [Nieco Aldoni](https://github.com/niecoaldoni) & [me](https://github.com/baskoroi)

## What this is

A space game demonstrating procedural generation, where the player, stranded on a planet called Proxima C, must survive on it while a rescue ship is coming on its way.

Story? Just clone, build and run the game :)

## Tools

* Adobe Illustrator CC 2020
* Sketch for Mac
* Xcode 11.5: Swift, SpriteKit

## What we've done

* Nieco: design
    * 2D game assets & tiles design
    * Foley sounds and background music 
    * Game design & story
    * Theme, both visually and auditorily
* Baskoro: tech
    * Swift / SpriteKit coding
    * Procedural generation for: (128 x 128 tiles - still wondering how to generate an infinite plane)
        * Land / acid -- using [Perlin noise](https://en.wikipedia.org/wiki/Perlin_noise)
        * Items distribution -- using [Poisson disc sampling](https://en.wikipedia.org/wiki/Supersampling#Poisson_disc)
    * Sweep line algorithm to reduce node count of acid tiles' physics bodies
        * Making one SKPhysicsBody per tile just makes the node count sickly huge.
    * Refactoring, etc.
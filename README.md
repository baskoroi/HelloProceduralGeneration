# Proxima C

By: [Nieco Aldoni](https://github.com/niecoaldoni) & [me](https://github.com/baskoroi)

## What this is

A space game we built to learn about game experience design (visuals and audio) and procedural generation.

Story: the player, an expedition robot agent, stranded on a planet called Proxima C, must survive on it while a rescue ship is coming on its way.

Further story? It's in the game. Just clone, build and run it. :)

## Tools

* Adobe Illustrator CC 2020, Sketch for Mac
* GarageBand for background music
* Adobe Audition for foley sound effects
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
    * [Sweep line algorithm](https://en.wikipedia.org/wiki/Sweep_line_algorithm) to reduce node count of acid tiles' physics bodies
        * Making one SKPhysicsBody per tile just makes the node count sickly huge - and blasts the memory.
    * Refactoring, etc.
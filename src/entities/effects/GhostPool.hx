package entities.effects;

import h2d.Tile;
import h2d.Object;

/**
 * Object pool for dash ghosts to avoid allocation during gameplay
 */
class GhostPool {
    var ghosts:Array<DashGhost>;
    var container:Object;
    var ghostTile:Tile;
    var poolSize:Int = 10;
    
    public function new(parent:Object) {
        container = new Object(parent);
        ghosts = [];
    }
    
    public function init(tile:Tile) {
        ghostTile = tile;
        
        // Pre-allocate ghosts
        for (i in 0...poolSize) {
            var ghost = new DashGhost(tile, container);
            ghost.visible = false;
            ghosts.push(ghost);
        }
    }
    
    public function spawn(x:Float, y:Float, facingRight:Bool):DashGhost {
        // Find an inactive ghost
        for (ghost in ghosts) {
            if (!ghost.isAlive) {
                ghost.spawn(x, y, facingRight);
                return ghost;
            }
        }
        
        // If all ghosts are active, create a new one
        var ghost = new DashGhost(ghostTile, container);
        ghost.spawn(x, y, facingRight);
        ghosts.push(ghost);
        return ghost;
    }
    
    public function update(dt:Float) {
        for (ghost in ghosts) {
            if (ghost.isAlive) {
                ghost.update(dt);
            }
        }
    }
    
    public function clear() {
        for (ghost in ghosts) {
            ghost.remove();
        }
        ghosts = [];
    }
}
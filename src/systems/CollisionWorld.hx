package systems;

import h2d.col.Bounds;
import h2d.col.Circle;
import h2d.col.Point;

class CollisionWorld {
    var tileSize:Int;
    var worldWidth:Int;
    var worldHeight:Int;
    
    // Spatial grid for optimization
    var grid:Map<String, Array<Bounds>>;
    var gridCellSize:Int = 64; // 4x4 tiles per cell
    
    // All wall bounds
    var wallBounds:Array<Bounds>;
    
    public function new(tilemap:Tilemap) {
        this.tileSize = Tilemap.TILE_SIZE;
        this.worldWidth = tilemap.widthInTiles;
        this.worldHeight = tilemap.heightInTiles;
        
        wallBounds = [];
        grid = new Map();
        
        // Convert solid tiles to bounds
        buildCollisionBounds(tilemap);
    }
    
    function buildCollisionBounds(tilemap:Tilemap) {
        // Scan tilemap and create bounds for solid tiles
        for (y in 0...worldHeight) {
            for (x in 0...worldWidth) {
                var tileId = tilemap.getTileAt(x, y);
                if (tilemap.isSolid(tileId)) {
                    var bounds = Bounds.fromValues(
                        x * tileSize,
                        y * tileSize,
                        tileSize,
                        tileSize
                    );
                    wallBounds.push(bounds);
                    
                    // Add to spatial grid
                    addToGrid(bounds);
                }
            }
        }
        
        // Merge adjacent bounds for optimization (optional)
        // mergeAdjacentBounds();
    }
    
    function addToGrid(bounds:Bounds) {
        var startX = Math.floor(bounds.x / gridCellSize);
        var startY = Math.floor(bounds.y / gridCellSize);
        var endX = Math.floor((bounds.x + bounds.width) / gridCellSize);
        var endY = Math.floor((bounds.y + bounds.height) / gridCellSize);
        
        for (gx in startX...endX + 1) {
            for (gy in startY...endY + 1) {
                var key = gx + "," + gy;
                if (!grid.exists(key)) {
                    grid[key] = [];
                }
                grid[key].push(bounds);
            }
        }
    }
    
    public function checkCircleCollision(circle:Circle):Bool {
        // Get relevant grid cells
        var bounds = getNearbyBounds(circle.x - circle.ray, circle.y - circle.ray, 
                                    circle.ray * 2, circle.ray * 2);
        
        // Check collision with each bound
        for (b in bounds) {
            if (circleVsBounds(circle, b)) {
                return true;
            }
        }
        
        return false;
    }
    
    public function resolveCircleCollision(circle:Circle, dx:Float, dy:Float):{x:Float, y:Float, hitX:Bool, hitY:Bool, cornerPush:{x:Float, y:Float}} {
        var result = {x: circle.x, y: circle.y, hitX: false, hitY: false, cornerPush: {x: 0.0, y: 0.0}};
        
        // Try full movement
        var testCircle = new Circle(circle.x + dx, circle.y + dy, circle.ray);
        if (!checkCircleCollision(testCircle)) {
            result.x += dx;
            result.y += dy;
            return result;
        }
        
        // Check for corner sliding opportunity
        var bounds = getNearbyBounds(testCircle.x - testCircle.ray, testCircle.y - testCircle.ray, 
                                    testCircle.ray * 2, testCircle.ray * 2);
        
        var smallestOverlap = Math.POSITIVE_INFINITY;
        var bestPush = {dx: 0.0, dy: 0.0};
        
        for (b in bounds) {
            if (circleVsBounds(testCircle, b)) {
                var sep = getMinimumSeparation(testCircle, b);
                if (sep.overlap > 0 && sep.overlap < smallestOverlap) {
                    smallestOverlap = sep.overlap;
                    bestPush = {dx: sep.dx, dy: sep.dy};
                }
            }
        }
        
        // If overlap is small enough, try corner sliding
        var cornerThreshold = circle.ray * 0.3; // 30% of radius
        if (smallestOverlap < cornerThreshold && smallestOverlap > 0) {
            // Apply push and retry movement
            var pushCircle = new Circle(circle.x + bestPush.dx, circle.y + bestPush.dy, circle.ray);
            var testPushed = new Circle(pushCircle.x + dx, pushCircle.y + dy, circle.ray);
            
            if (!checkCircleCollision(testPushed)) {
                result.x = testPushed.x;
                result.y = testPushed.y;
                result.cornerPush = {x: bestPush.dx, y: bestPush.dy};
                return result;
            }
        }
        
        // Fall back to regular collision resolution
        // Try horizontal movement only
        testCircle.x = circle.x + dx;
        testCircle.y = circle.y;
        if (!checkCircleCollision(testCircle)) {
            result.x += dx;
            result.hitY = true;
        } else {
            result.hitX = true;
            
            // Try small horizontal steps to get as close as possible
            var steps = 10;
            var stepX = dx / steps;
            for (i in 1...steps) {
                testCircle.x = circle.x + stepX * i;
                if (checkCircleCollision(testCircle)) {
                    result.x = circle.x + stepX * (i - 1);
                    break;
                }
            }
        }
        
        // Try vertical movement only
        testCircle.x = result.x;
        testCircle.y = circle.y + dy;
        if (!checkCircleCollision(testCircle)) {
            result.y += dy;
        } else {
            result.hitY = true;
            
            // Try small vertical steps to get as close as possible
            var steps = 10;
            var stepY = dy / steps;
            for (i in 1...steps) {
                testCircle.y = circle.y + stepY * i;
                if (checkCircleCollision(testCircle)) {
                    result.y = circle.y + stepY * (i - 1);
                    break;
                }
            }
        }
        
        return result;
    }
    
    function getNearbyBounds(x:Float, y:Float, w:Float, h:Float):Array<Bounds> {
        var result = [];
        var checked = new Map<Bounds, Bool>();
        
        var startX = Math.floor(x / gridCellSize);
        var startY = Math.floor(y / gridCellSize);
        var endX = Math.floor((x + w) / gridCellSize);
        var endY = Math.floor((y + h) / gridCellSize);
        
        for (gx in startX...endX + 1) {
            for (gy in startY...endY + 1) {
                var key = gx + "," + gy;
                if (grid.exists(key)) {
                    for (bounds in grid[key]) {
                        if (!checked.exists(bounds)) {
                            checked[bounds] = true;
                            result.push(bounds);
                        }
                    }
                }
            }
        }
        
        return result;
    }
    
    function circleVsBounds(circle:Circle, bounds:Bounds):Bool {
        // Find closest point on bounds to circle center
        var closestX = Math.max(bounds.x, Math.min(circle.x, bounds.x + bounds.width));
        var closestY = Math.max(bounds.y, Math.min(circle.y, bounds.y + bounds.height));
        
        // Check if distance is less than radius
        var dx = circle.x - closestX;
        var dy = circle.y - closestY;
        
        return (dx * dx + dy * dy) < (circle.ray * circle.ray);
    }
    
    function getMinimumSeparation(circle:Circle, bounds:Bounds):{dx:Float, dy:Float, overlap:Float} {
        // Find closest point on bounds to circle center
        var closestX = Math.max(bounds.x, Math.min(circle.x, bounds.x + bounds.width));
        var closestY = Math.max(bounds.y, Math.min(circle.y, bounds.y + bounds.height));
        
        var dx = circle.x - closestX;
        var dy = circle.y - closestY;
        var dist = Math.sqrt(dx * dx + dy * dy);
        
        if (dist < 0.001) {
            // Circle center is inside the box, push out nearest edge
            var leftDist = circle.x - bounds.x;
            var rightDist = (bounds.x + bounds.width) - circle.x;
            var topDist = circle.y - bounds.y;
            var bottomDist = (bounds.y + bounds.height) - circle.y;
            
            var minDist = Math.min(Math.min(leftDist, rightDist), Math.min(topDist, bottomDist));
            
            if (minDist == leftDist) return {dx: -(leftDist + circle.ray), dy: 0, overlap: leftDist + circle.ray};
            if (minDist == rightDist) return {dx: rightDist + circle.ray, dy: 0, overlap: rightDist + circle.ray};
            if (minDist == topDist) return {dx: 0, dy: -(topDist + circle.ray), overlap: topDist + circle.ray};
            return {dx: 0, dy: bottomDist + circle.ray, overlap: bottomDist + circle.ray};
        }
        
        var overlap = circle.ray - dist;
        if (overlap <= 0) return {dx: 0, dy: 0, overlap: 0};
        
        // Normalize and scale by overlap
        return {
            dx: (dx / dist) * overlap,
            dy: (dy / dist) * overlap,
            overlap: overlap
        };
    }
    
    public function debugDraw(g:h2d.Graphics) {
        g.clear();
        g.lineStyle(1, 0xFF0000, 0.5);
        
        for (bounds in wallBounds) {
            g.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
        }
    }
}
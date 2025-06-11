package systems;

import systems.Tilemap;
import utils.TilesetGenerator;
import utils.GameConstants;

/**
 * Level loading and generation system
 * 
 * Handles loading level data from various sources:
 * - JSON files for designed levels
 * - Procedural generation for test levels
 * - CastleDB integration (future)
 * 
 * Level data format:
 * ```json
 * {
 *     "width": 40,
 *     "height": 30,
 *     "tileSize": 16,
 *     "tiles": [0,1,1,0...],
 *     "collisionTiles": [false, true, true, false]
 * }
 * ```
 * 
 * Tile types (for test level):
 * - 0: Empty space
 * - 1: Wall (collision)
 * - 2: Obstacle (collision)
 * - 3: Special tile (collision)
 * 
 * @see Tilemap for the tilemap system
 * @see CollisionWorld for how collision data is used
 */
class LevelLoader {
    
    /**
     * Load a test level with procedural generation
     * Creates a bordered arena with scattered obstacles
     * 
     * @param tilemap The tilemap to populate
     * @param width Level width in tiles (default: 40)
     * @param height Level height in tiles (default: 30)
     */
    public static function loadTestLevel(tilemap:Tilemap, width:Int = 40, height:Int = 30):Void {
        // Create test tileset
        var tilesetImage = TilesetGenerator.createTestTileset();
        
        // Create level data structure
        var levelData = {
            width: width,
            height: height,
            tileSize: GameConstants.TILE_SIZE,
            tiles: [],
            collisionTiles: [false, true, true, true]  // Tile 0 is passable, 1-3 are solid
        };
        
        // Generate level procedurally
        for (y in 0...height) {
            for (x in 0...width) {
                var tile = 0;  // Default to empty
                
                // === Create borders ===
                if (x == 0 || x == width-1 || y == 0 || y == height-1) {
                    tile = 1;  // Wall tile
                }
                // === Add regular obstacles ===
                else if ((x % 8 == 3 || x % 8 == 4) && (y % 6 == 2 || y % 6 == 3)) {
                    tile = 2;  // Obstacle tile
                }
                // === Add special tiles at obstacle centers ===
                else if (x % 8 == 3 && y % 6 == 2) {
                    tile = 3;  // Special tile
                }
                
                levelData.tiles.push(tile);
            }
        }
        
        // Load the generated data into tilemap
        tilemap.loadFromData(levelData, tilesetImage);
        
        trace('Test level loaded: ${width}x${height} tiles');
    }
    
    /**
     * Load a level from JSON file
     * 
     * @param tilemap The tilemap to populate
     * @param jsonPath Path to the JSON file
     * @param tilesetPath Path to the tileset image
     */
    public static function loadFromJSON(tilemap:Tilemap, jsonPath:String, tilesetPath:String):Void {
        // TODO: Implement JSON loading when resource system is set up
        // This will use hxd.Res to load the JSON and tileset
        trace('JSON level loading not yet implemented');
    }
    
    /**
     * Create an empty level
     * Useful for level editors or dynamic generation
     * 
     * @param tilemap The tilemap to populate
     * @param width Level width in tiles
     * @param height Level height in tiles
     * @param defaultTile Default tile index to fill with
     */
    public static function createEmpty(tilemap:Tilemap, width:Int, height:Int, defaultTile:Int = 0):Void {
        var tilesetImage = TilesetGenerator.createTestTileset();
        
        var levelData = {
            width: width,
            height: height,
            tileSize: GameConstants.TILE_SIZE,
            tiles: [],
            collisionTiles: [false, true, true, true]
        };
        
        // Fill with default tile
        for (i in 0...(width * height)) {
            levelData.tiles.push(defaultTile);
        }
        
        tilemap.loadFromData(levelData, tilesetImage);
        
        trace('Empty level created: ${width}x${height} tiles');
    }
    
    /**
     * Generate a random dungeon level
     * Uses simple room and corridor generation
     * 
     * @param tilemap The tilemap to populate
     * @param width Level width in tiles
     * @param height Level height in tiles
     * @param roomCount Number of rooms to generate
     */
    public static function generateDungeon(tilemap:Tilemap, width:Int, height:Int, roomCount:Int = 10):Void {
        // TODO: Implement dungeon generation algorithm
        // For now, just create a test level
        loadTestLevel(tilemap, width, height);
    }
    
    /**
     * Load level metadata (spawn points, triggers, etc.)
     * This would be called after loading the tilemap
     * 
     * @param levelData The loaded level data
     * @return Object containing spawn points, triggers, etc.
     */
    public static function loadMetadata(levelData:Dynamic):{playerSpawn:{x:Int, y:Int}, triggers:Array<Dynamic>} {
        // Default spawn point (grid coordinates)
        var metadata = {
            playerSpawn: {x: 10, y: 10},
            triggers: []
        };
        
        // TODO: Parse actual metadata from level data
        
        return metadata;
    }
}
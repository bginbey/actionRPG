package systems;

import h2d.Tile;
import h2d.TileGroup;
import h2d.Object;

class Tilemap extends Object {
    public static inline var TILE_SIZE = 16;
    
    public var widthInTiles:Int;
    public var heightInTiles:Int;
    public var widthInPixels(get, never):Int;
    public var heightInPixels(get, never):Int;
    
    var tileGroup:TileGroup;
    var tiles:Array<Array<Int>>;
    var tileset:Array<Tile>;
    var collisionData:Array<Bool>;
    
    public function new(parent:Object) {
        super(parent);
        
        tiles = [];
        collisionData = [];
        tileset = [];
    }
    
    public function loadFromData(data:TilemapData, tilesetImage:Tile) {
        widthInTiles = data.width;
        heightInTiles = data.height;
        
        createTileset(tilesetImage, data.tileSize);
        
        tiles = [];
        for (y in 0...heightInTiles) {
            tiles[y] = [];
            for (x in 0...widthInTiles) {
                var idx = y * widthInTiles + x;
                tiles[y][x] = data.tiles[idx];
            }
        }
        
        if (data.collisionTiles != null) {
            collisionData = data.collisionTiles.copy();
        }
        
        buildTileGroup();
    }
    
    function createTileset(baseImage:Tile, tileSize:Int) {
        tileset = [];
        
        var tilesPerRow = Std.int(baseImage.width / tileSize);
        var tilesPerCol = Std.int(baseImage.height / tileSize);
        
        for (y in 0...tilesPerCol) {
            for (x in 0...tilesPerRow) {
                tileset.push(baseImage.sub(
                    x * tileSize, 
                    y * tileSize, 
                    tileSize, 
                    tileSize
                ));
            }
        }
    }
    
    function buildTileGroup() {
        if (tileGroup != null) {
            tileGroup.remove();
        }
        
        if (tileset.length == 0) return;
        
        tileGroup = new TileGroup(tileset[0], this);
        
        for (y in 0...heightInTiles) {
            for (x in 0...widthInTiles) {
                var tileId = tiles[y][x];
                if (tileId >= 0 && tileId < tileset.length) {
                    tileGroup.add(
                        x * TILE_SIZE, 
                        y * TILE_SIZE, 
                        tileset[tileId]
                    );
                }
            }
        }
    }
    
    public function getTileAt(x:Int, y:Int):Int {
        if (x < 0 || x >= widthInTiles || y < 0 || y >= heightInTiles) {
            return -1;
        }
        return tiles[y][x];
    }
    
    public function setTileAt(x:Int, y:Int, tileId:Int) {
        if (x < 0 || x >= widthInTiles || y < 0 || y >= heightInTiles) {
            return;
        }
        tiles[y][x] = tileId;
        buildTileGroup();
    }
    
    public function isSolid(tileId:Int):Bool {
        if (tileId < 0 || tileId >= collisionData.length) {
            return false;
        }
        return collisionData[tileId];
    }
    
    public function getTileAtPixel(pixelX:Float, pixelY:Float):Int {
        var tileX = Math.floor(pixelX / TILE_SIZE);
        var tileY = Math.floor(pixelY / TILE_SIZE);
        return getTileAt(tileX, tileY);
    }
    
    public function isSolidAtPixel(pixelX:Float, pixelY:Float):Bool {
        var tileId = getTileAtPixel(pixelX, pixelY);
        return isSolid(tileId);
    }
    
    inline function get_widthInPixels():Int {
        return widthInTiles * TILE_SIZE;
    }
    
    inline function get_heightInPixels():Int {
        return heightInTiles * TILE_SIZE;
    }
}

typedef TilemapData = {
    var width:Int;
    var height:Int;
    var tileSize:Int;
    var tiles:Array<Int>;
    var ?collisionTiles:Array<Bool>;
}
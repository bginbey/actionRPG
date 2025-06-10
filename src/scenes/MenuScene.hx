package scenes;

import h2d.Text;
import h2d.Interactive;
import h2d.Graphics;
import ui.PixelText;

class MenuScene extends Scene {
    var titleText: Text;
    var menuItems: Array<MenuItem> = [];
    var selectedIndex: Int = 0;
    
    static inline var MENU_ITEM_SPACING: Float = 40;
    static inline var MENU_START_Y: Float = 200;
    
    public function new(app: Main) {
        super(app, "menu");
    }
    
    override public function enter(): Void {
        super.enter();
        
        // Create title
        var pixelTitle = new PixelText(this);
        pixelTitle.text = "ACTION RPG";
        pixelTitle.textAlign = Center;
        pixelTitle.setPixelScale(4);
        pixelTitle.x = width * 0.5;
        pixelTitle.y = 80;
        titleText = pixelTitle;
        
        // Create menu items
        createMenuItem("START GAME", 0, startGame);
        createMenuItem("OPTIONS", 1, showOptions);
        createMenuItem("QUIT", 2, quitGame);
        
        // Select first item
        updateSelection();
    }
    
    function createMenuItem(label: String, index: Int, callback: Void -> Void): Void {
        var item = new MenuItem(this);
        item.text = label;
        item.callback = callback;
        item.index = index;
        
        var text = new PixelText(item);
        text.text = label;
        text.textAlign = Center;
        text.setPixelScale(2);
        
        item.textField = text;
        item.x = width * 0.5;
        item.y = MENU_START_Y + (index * MENU_ITEM_SPACING);
        
        // Create interactive area
        var bounds = text.getBounds();
        var interactive = new Interactive(bounds.width, bounds.height, item);
        interactive.x = -bounds.width * 0.5;
        interactive.y = 0;
        
        interactive.onOver = function(_) {
            selectedIndex = index;
            updateSelection();
        };
        
        interactive.onClick = function(_) {
            selectCurrentItem();
        };
        
        menuItems.push(item);
    }
    
    override public function update(dt: Float): Void {
        super.update(dt);
        
        // Keyboard navigation
        if (hxd.Key.isPressed(hxd.Key.UP)) {
            selectedIndex = (selectedIndex - 1 + menuItems.length) % menuItems.length;
            updateSelection();
        } else if (hxd.Key.isPressed(hxd.Key.DOWN)) {
            selectedIndex = (selectedIndex + 1) % menuItems.length;
            updateSelection();
        } else if (hxd.Key.isPressed(hxd.Key.ENTER) || hxd.Key.isPressed(hxd.Key.SPACE)) {
            selectCurrentItem();
        }
    }
    
    function updateSelection(): Void {
        for (i in 0...menuItems.length) {
            var item = menuItems[i];
            if (i == selectedIndex) {
                item.textField.color.set(1.0, 1.0, 0.0); // Yellow
                item.scaleX = item.scaleY = 1.1;
            } else {
                item.textField.color.set(1.0, 1.0, 1.0); // White
                item.scaleX = item.scaleY = 1.0;
            }
        }
    }
    
    function selectCurrentItem(): Void {
        if (selectedIndex >= 0 && selectedIndex < menuItems.length) {
            var item = menuItems[selectedIndex];
            if (item.callback != null) {
                item.callback();
            }
        }
    }
    
    function startGame(): Void {
        #if debug
        trace("Starting game...");
        #end
        // Transition to game scene with fade
        app.sceneManager.switchTo("game", {
            duration: 0.5,
            fadeColor: 0x000000,
            onComplete: null
        });
    }
    
    function showOptions(): Void {
        #if debug
        trace("Options not implemented yet");
        #end
    }
    
    function quitGame(): Void {
        #if debug
        trace("Quit requested");
        #end
        #if sys
        Sys.exit(0);
        #end
    }
    
    override public function resize(): Void {
        super.resize();
        
        if (titleText != null) {
            titleText.x = width * 0.5;
        }
        
        for (item in menuItems) {
            item.x = width * 0.5;
        }
    }
}

class MenuItem extends h2d.Object {
    public var text: String;
    public var callback: Void -> Void;
    public var index: Int;
    public var textField: Text;
    
    public function new(?parent) {
        super(parent);
    }
}
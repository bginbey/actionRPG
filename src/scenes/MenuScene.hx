package scenes;

import h2d.Text;
import ui.PixelText;

class MenuScene extends Scene {
    var menuItems: Array<MenuItem> = [];
    var selectedIndex: Int = 0;
    
    static inline var MENU_ITEM_SPACING: Float = 30;
    static inline var MENU_ITEM_COUNT: Int = 4;  // Space for 4 items
    
    public function new(app: Main) {
        super(app, "menu");
    }
    
    override public function enter(): Void {
        super.enter();
        
        // Clear any existing menu items
        for (item in menuItems) {
            item.remove();
        }
        menuItems = [];
        selectedIndex = 0;
        
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
        
        // Calculate vertical centering for menu items
        var totalHeight = (menuItems.length + 1) * MENU_ITEM_SPACING;
        var startY = (gameHeight - totalHeight) * 0.5;
        
        item.x = gameWidth * 0.5;
        item.y = startY + (index * MENU_ITEM_SPACING);
        
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
                item.scaleX = item.scaleY = 1.2;
            } else {
                item.textField.color.set(0.7, 0.7, 0.7); // Light gray
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
        
        // Recalculate menu positions
        var totalHeight = menuItems.length * MENU_ITEM_SPACING;
        var startY = (gameHeight - totalHeight) * 0.5;
        
        for (i in 0...menuItems.length) {
            var item = menuItems[i];
            item.x = gameWidth * 0.5;
            item.y = startY + (i * MENU_ITEM_SPACING);
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
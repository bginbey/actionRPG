package entities.effects;

import h2d.Graphics;
import utils.ColorPalette;
import utils.GameConstants;

/**
 * Visual effect for sword swing
 * 
 * Creates an arc-shaped swing effect that follows the attack animation.
 * The effect is temporary and automatically removes itself after the swing duration.
 * 
 * Features:
 * - Arc rendering based on attack direction
 * - Fade out animation
 * - Combo-based coloring
 * 
 * @see Player for attack integration
 */
class SwordSwing extends h2d.Object {
    var graphics:Graphics;
    var duration:Float;
    var elapsed:Float = 0;
    var attackAngle:Float;
    var comboCount:Int;
    
    /**
     * Create a new sword swing effect
     * @param parent Parent container
     * @param x Center X position
     * @param y Center Y position
     * @param angle Attack angle in radians
     * @param comboCount Current combo for visual variation
     */
    public function new(parent:h2d.Object, x:Float, y:Float, angle:Float, comboCount:Int) {
        super(parent);
        
        this.x = x;
        this.y = y;
        this.attackAngle = angle;
        this.comboCount = comboCount;
        this.duration = GameConstants.SWORD_SWING_DURATION;
        
        graphics = new Graphics(this);
        drawSwing();
    }
    
    function drawSwing() {
        graphics.clear();
        
        // Choose color based on combo
        var color = switch(comboCount) {
            case 1: ColorPalette.LIGHT_GRAY;
            case 2: ColorPalette.YELLOW;
            case 3: ColorPalette.ORANGE;
            default: ColorPalette.LIGHT_GRAY;
        }
        
        // Calculate alpha based on elapsed time
        var progress = elapsed / duration;
        var alpha = 1.0 - progress;
        
        graphics.beginFill(color, alpha * 0.3);
        graphics.lineStyle(2, color, alpha);
        
        // Draw arc centered on attack angle
        var arcSpread = Math.PI/3;  // 60 degree arc
        var startAngle = attackAngle - arcSpread/2;
        var endAngle = attackAngle + arcSpread/2;
        var radius = GameConstants.SWORD_HITBOX_OFFSET + GameConstants.SWORD_HITBOX_WIDTH/2;
        
        // Draw arc segments
        var segments = 8;
        graphics.moveTo(0, 0);
        for (i in 0...segments + 1) {
            var t = i / segments;
            var angle = startAngle + (endAngle - startAngle) * t;
            var px = Math.cos(angle) * radius;
            var py = Math.sin(angle) * radius;
            graphics.lineTo(px, py);
        }
        graphics.lineTo(0, 0);
        graphics.endFill();
    }
    
    public function update(dt:Float) {
        elapsed += dt;
        
        if (elapsed >= duration) {
            remove();
            return;
        }
        
        // Redraw with new alpha
        drawSwing();
    }
}
package systems;

import h2d.Graphics;
import entities.Player;
import systems.CollisionWorld;
import systems.effects.particles.ParticleSystem;
import entities.effects.RainEffect;
import utils.GameConstants;

/**
 * Debug visualization system
 * 
 * Provides visual debugging tools for development:
 * - Collision shapes and boundaries
 * - Movement vectors and velocities  
 * - Entity states (invincible, dashing, etc.)
 * - Collision response indicators
 * - Corner push visualization
 * 
 * Controls:
 * - ` (backtick) - Toggle debug view
 * - Shows different colors for different states
 * - Displays collision responses in real-time
 * 
 * Color coding:
 * - Green: Normal state, successful movement
 * - Red: Blocked movement, collision boundaries
 * - Yellow: Actual movement vectors
 * - Cyan: Dashing state
 * - White: Invincible state
 * - Orange: Corner push origin
 * - Blue: Corner push direction
 * 
 * @see GameScene for integration
 * @see CollisionWorld for collision visualization
 */
class DebugRenderer {
    var graphics:Graphics;
    var enabled:Bool = false;
    
    /**
     * Create a new debug renderer
     * @param graphics Graphics object to draw on (usually in world space)
     */
    public function new(graphics:Graphics) {
        this.graphics = graphics;
    }
    
    /**
     * Toggle debug rendering on/off
     */
    public function toggle():Void {
        enabled = !enabled;
        if (!enabled) {
            graphics.clear();
        }
    }
    
    /**
     * Check if debug rendering is enabled
     */
    public function isEnabled():Bool {
        return enabled;
    }
    
    /**
     * Clear debug graphics
     */
    public function clear():Void {
        graphics.clear();
    }
    
    /**
     * Main debug rendering function
     * Call this each frame when debug mode is active
     * 
     * @param collisionWorld World collision data to visualize
     * @param player Player entity to debug
     */
    public function render(collisionWorld:CollisionWorld, player:Player):Void {
        if (!enabled) return;
        
        graphics.clear();
        
        // Draw collision world bounds
        collisionWorld.debugDraw(graphics);
        
        // Draw player debug info
        drawPlayerDebug(player);
    }
    
    /**
     * Draw player-specific debug information
     */
    function drawPlayerDebug(player:Player):Void {
        // === Player sprite boundaries (red border) ===
        // Shows the visual sprite area (not collision)
        graphics.lineStyle(1, 0xFF0000, 1);
        graphics.drawRect(player.px - 16, player.py - 16, 32, 32);
        
        // === Player collision circle ===
        // Color indicates current state
        var colliderColor = player.isInvincible ? 0xFFFFFF :     // White when invincible
                           (player.isDashing ? 0x00FFFF :         // Cyan when dashing
                                              0x00FF00);          // Green normally
        graphics.lineStyle(2, colliderColor, 1);
        graphics.drawCircle(player.px, player.py, player.radius);
        
        // === Desired movement vector ===
        // Shows where player is trying to move (red if blocked)
        if (player.desiredDx != 0 || player.desiredDy != 0) {
            var color = (player.lastHitX || player.lastHitY) ? 0xFF0000 : 0x00FF00;
            graphics.lineStyle(3, color, 0.8);
            graphics.moveTo(player.px, player.py);
            graphics.lineTo(
                player.px + player.desiredDx * GameConstants.DEBUG_VECTOR_SCALE, 
                player.py + player.desiredDy * GameConstants.DEBUG_VECTOR_SCALE
            );
            
            // === Collision indicators ===
            // Shows which axis is blocked
            if (player.lastHitX) {
                graphics.lineStyle(2, 0xFF0000, 1);
                var dir = player.desiredDx > 0 ? 1 : -1;
                graphics.moveTo(player.px + dir * player.radius, player.py - player.radius);
                graphics.lineTo(player.px + dir * player.radius, player.py + player.radius);
            }
            if (player.lastHitY) {
                graphics.lineStyle(2, 0xFF0000, 1);
                var dir = player.desiredDy > 0 ? 1 : -1;
                graphics.moveTo(player.px - player.radius, player.py + dir * player.radius);
                graphics.lineTo(player.px + player.radius, player.py + dir * player.radius);
            }
        }
        
        // === Actual movement vector (yellow) ===
        // Shows actual movement after collision resolution
        if (player.dx != 0 || player.dy != 0) {
            graphics.lineStyle(2, 0xFFFF00, 1);
            graphics.moveTo(player.px, player.py);
            graphics.lineTo(
                player.px + player.dx * GameConstants.DEBUG_VECTOR_SCALE, 
                player.py + player.dy * GameConstants.DEBUG_VECTOR_SCALE
            );
        }
        
        // === Corner push visualization ===
        // Shows when corner sliding is active
        if (player.lastCornerPush.x != 0 || player.lastCornerPush.y != 0) {
            // Orange circle at push origin
            graphics.lineStyle(2, 0xFF8800, 1);
            graphics.drawCircle(
                player.px - player.lastCornerPush.x, 
                player.py - player.lastCornerPush.y, 
                3
            );
            
            // Blue arrow showing push direction
            graphics.lineStyle(3, 0x00CCFF, 0.8);
            graphics.moveTo(
                player.px - player.lastCornerPush.x, 
                player.py - player.lastCornerPush.y
            );
            graphics.lineTo(player.px, player.py);
        }
        
        // === Player center point ===
        // Precise position indicator
        graphics.lineStyle(1, 0xFFFFFF, 1);
        graphics.drawCircle(player.px, player.py, 2);
        
        // === Facing direction indicator ===
        // Show which way player is facing
        graphics.lineStyle(2, 0x00FF00, 0.8);  // Green arrow
        var arrowLength = 20;
        var angle = player.getFacingAngle();
        graphics.moveTo(player.px, player.py);
        graphics.lineTo(
            player.px + Math.cos(angle) * arrowLength,
            player.py + Math.sin(angle) * arrowLength
        );
        
        // === Attack hitbox ===
        // Show active attack hitbox
        var hitbox = player.getCurrentHitbox();
        if (hitbox != null && hitbox.bounds != null) {
            graphics.lineStyle(2, 0xFF00FF, 0.8);  // Magenta for attack
            graphics.drawRect(
                hitbox.bounds.x,
                hitbox.bounds.y,
                hitbox.bounds.width,
                hitbox.bounds.height
            );
        }
    }
    
    /**
     * Get debug text for display
     * 
     * @param cameraDebugMode Whether camera is in debug mode
     * @param canDash Whether player can currently dash
     * @param dashCooldownPercent Dash cooldown percentage (0-100)
     * @param particleSystem Particle system for stats
     * @param rainEffect Rain effect for status
     * @return Formatted debug text
     */
    public function getDebugText(
        cameraDebugMode:Bool,
        canDash:Bool,
        dashCooldownPercent:Float,
        ?particleSystem:ParticleSystem,
        ?rainEffect:RainEffect,
        ?player:Player
    ):String {
        var text = "";
        
        if (cameraDebugMode) {
            text = "FREE CAM MODE - WASD to move camera";
        }
        
        if (enabled) {
            text += " [DEBUG ON]";
        }
        
        if (!canDash) {
            var cooldown = Math.ceil(dashCooldownPercent * 100);
            text += " [DASH CD: " + cooldown + "%]";
        }
        
        if (particleSystem != null && enabled) {
            text += " [Particles: " + particleSystem.totalActiveParticles + "]";
        }
        
        if (rainEffect != null && enabled) {
            text += rainEffect.isActive ? " [RAIN ON]" : " [RAIN OFF]";
        }
        
        if (player != null && enabled) {
            if (player.isAttacking) {
                text += " [ATTACKING]";
            }
            if (player.getComboCount() > 0) {
                text += " [COMBO: " + player.getComboCount() + "]";
            }
            text += " [HP: " + Math.ceil(player.health) + "/" + Math.ceil(player.maxHealth) + "]";
        }
        
        return text;
    }
}
# Player Animation Guide

## Animation States & Timing

### 1. IDLE (6 frames) - Loop
Frame timing at 60 FPS:
- Frame 1: 10 ticks (0.167s) - neutral pose
- Frame 2: 10 ticks (0.167s) - slight inhale
- Frame 3: 10 ticks (0.167s) - full inhale
- Frame 4: 10 ticks (0.167s) - hold
- Frame 5: 10 ticks (0.167s) - exhale
- Frame 6: 10 ticks (0.167s) - return to neutral
- **Total**: 1 second per breath cycle

Key poses:
- Subtle breathing motion
- Maybe slight weapon/cloth movement
- Keep feet planted

### 2. WALK (8 frames) - Loop
Frame timing at 60 FPS:
- Each frame: 6 ticks (0.1s)
- **Total**: 0.8 seconds per walk cycle

Key poses:
- Frame 1: Right foot forward, left arm forward
- Frame 2-3: Transition
- Frame 4: Neutral passing position
- Frame 5: Left foot forward, right arm forward
- Frame 6-7: Transition
- Frame 8: Neutral passing position

### 3. DASH (3 frames) - Play once
Frame timing at 60 FPS:
- Frame 1: 3 ticks (0.05s) - anticipation
- Frame 2: 6 ticks (0.1s) - dash pose (held during dash)
- Frame 3: 3 ticks (0.05s) - recovery
- **Total**: 0.2 seconds (matches dash duration)

Key poses:
- Frame 1: Slight crouch/lean back
- Frame 2: Full forward lean, one foot back
- Frame 3: Settling into run

### 4. ATTACK COMBO (6 frames each)

**Canvas Size**: Use 64x64 pixels for all attack frames (instead of 32x32)
- Character body remains in the center 32x32 area
- Sword/weapon extends into the extra space
- Pivot point at (32, 32) for 64x64 sprites
- This allows the weapon to visually match the 20px hit range

#### Attack 1 - Horizontal Slash
- Frame 1-2: 2 ticks each - Wind up
- Frame 3: 2 ticks - Swing start
- Frame 4: 3 ticks - Contact point
- Frame 5: 3 ticks - Follow through
- Frame 6: 4 ticks - Recovery
- **Total**: 0.27 seconds

#### Attack 2 - Diagonal Slash
- Frame 1: 2 ticks - Quick setup
- Frame 2-3: 2 ticks each - Swing
- Frame 4: 3 ticks - Contact
- Frame 5-6: 3 ticks each - Recovery
- **Total**: 0.25 seconds

#### Attack 3 - Spin Attack
- Frame 1-2: 3 ticks each - Big wind up
- Frame 3-4: 2 ticks each - Spin
- Frame 5: 3 ticks - End pose
- Frame 6: 5 ticks - Recovery
- **Total**: 0.3 seconds

### 5. HURT (3 frames) - Play once
Frame timing at 60 FPS:
- Frame 1: 4 ticks - Impact
- Frame 2: 6 ticks - Max recoil
- Frame 3: 6 ticks - Recovery
- **Total**: 0.27 seconds

Key poses:
- Knocked back slightly
- Head thrown back
- Arms out for balance

### 6. DEATH (6 frames) - Play once
Frame timing at 60 FPS:
- Frame 1-2: 5 ticks each - Stagger
- Frame 3: 8 ticks - Falling
- Frame 4: 8 ticks - Hit ground
- Frame 5-6: 10 ticks each - Settle
- **Total**: 0.77 seconds

Key poses:
- Dramatic stagger
- Fall to knees
- Collapse forward or backward

## Direction Handling

The game handles 8 directions through:
- **Sprite Flipping**: Draw all sprites facing RIGHT
- **Rotation**: Applied in code for diagonal attacks
- You only need to create RIGHT-facing sprites!

## Sprite Guidelines

### Pivot Point
- Always centered at pixel (16, 16)
- Keep action within the 32x32 bounds
- Sword can extend slightly outside during attacks

### Collision Reference
- Player collision circle: 12 pixel radius from center
- Keep feet and body within this circle
- Arms and weapons can extend beyond

### Visual Hierarchy
1. Clear silhouette - readable at small size
2. Distinct poses for each animation
3. Consistent volumes (don't shrink/grow the character)
4. Secondary motion on clothes/hair/weapons

### Attack Arc Reference
- Attack hitbox extends 20 pixels from player center
- 60-degree arc for sword swing
- Sword should visually match this range

## Technical Notes

### Current Implementation
- Animations use h2d.Anim class
- Frame rate can be adjusted per animation
- All frames should be same size (32x32)
- Use transparency for empty areas

### Future Implementation
Will need to update:
1. SpriteGenerator.hx to load from files
2. Player.hx to handle new animation states
3. Add state machine for smooth transitions

## Quick Checklist Per Animation

- [ ] All frames are 32x32 pixels (64x64 for attack animations)
- [ ] Character faces RIGHT
- [ ] Pivot is at center (16,16 for 32x32, 32,32 for 64x64)
- [ ] Uses Resurrect 64 palette colors
- [ ] Clear readable silhouette
- [ ] Consistent volume/proportions
- [ ] No anti-aliasing (pure pixel art)
- [ ] Transparent background
- [ ] Saved as PNG

## Testing Your Sprites

1. Place files in correct folders
2. Each frame should connect smoothly to the next
3. Loop animations should connect frame 8 to frame 1
4. Test at game speed to check timing
5. Ensure readability when scaled up 2x-4x
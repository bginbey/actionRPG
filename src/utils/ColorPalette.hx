package utils;

class ColorPalette {
    public static inline var PALETTE_NAME = "Resurrect 64";
    
    // Row 1 - Blacks to Grays
    public static inline var BLACK = 0x2e222f;
    public static inline var DARK_GRAY = 0x3e3546;
    public static inline var GRAY = 0x625565;
    public static inline var LIGHT_GRAY = 0x966c6c;
    public static inline var SILVER = 0xab947a;
    public static inline var LIGHT_SILVER = 0x694f62;
    public static inline var WARM_GRAY = 0x7f708a;
    public static inline var PALE_GRAY = 0x9babb2;
    
    // Row 2 - Blues and Cyans
    public static inline var DARK_BLUE = 0x0c5f89;
    public static inline var BLUE = 0x3ca370;
    public static inline var LIGHT_BLUE = 0x5fcde8;
    public static inline var CYAN = 0x8be5ff;
    public static inline var PALE_BLUE = 0xc0e3ff;
    public static inline var SKY_BLUE = 0x73bed3;
    public static inline var TEAL = 0x4d8cbf;
    public static inline var DEEP_TEAL = 0x3a5f8f;
    
    // Row 3 - Greens
    public static inline var DARK_GREEN = 0x306850;
    public static inline var GREEN = 0x4e8b57;
    public static inline var LIGHT_GREEN = 0x7fb069;
    public static inline var LIME = 0xa8ca58;
    public static inline var PALE_GREEN = 0xc8d978;
    public static inline var YELLOW_GREEN = 0xe0f8a1;
    public static inline var MINT = 0xb8d89f;
    public static inline var SAGE = 0x90a99f;
    
    // Row 4 - Warm Colors
    public static inline var DARK_BROWN = 0x4f3b3b;
    public static inline var BROWN = 0x6e5555;
    public static inline var LIGHT_BROWN = 0x8b6d6d;
    public static inline var TAN = 0xa67f7f;
    public static inline var PEACH = 0xbf9f9f;
    public static inline var CORAL = 0xd8bfbf;
    public static inline var PINK = 0xf0dfdf;
    public static inline var PALE_PINK = 0xffffff;
    
    // Row 5 - Reds and Oranges
    public static inline var DARK_RED = 0x6e2733;
    public static inline var RED = 0x9e4444;
    public static inline var BRIGHT_RED = 0xbe6262;
    public static inline var ORANGE_RED = 0xd68989;
    public static inline var ORANGE = 0xe8a666;
    public static inline var LIGHT_ORANGE = 0xf3c57b;
    public static inline var YELLOW = 0xfee893;
    public static inline var PALE_YELLOW = 0xfcfcfc;
    
    // Row 6 - Purples and Magentas
    public static inline var DARK_PURPLE = 0x45283c;
    public static inline var PURPLE = 0x663c59;
    public static inline var LIGHT_PURPLE = 0x8e5176;
    public static inline var MAGENTA = 0xba6f93;
    public static inline var PINK_PURPLE = 0xd89bb5;
    public static inline var LAVENDER = 0xe8c5d6;
    public static inline var PALE_LAVENDER = 0xf5e9f5;
    public static inline var WHITE = 0xffffff;
    
    // Row 7 & 8 - Additional shades
    public static inline var INK = 0x222034;
    public static inline var SHADOW = 0x393954;
    public static inline var MID_TONE = 0x514c6b;
    public static inline var HIGHLIGHT = 0x7a7394;
    public static inline var CREAM = 0xede6e3;
    public static inline var BONE = 0xdbc8b0;
    public static inline var SAND = 0xab9b89;
    public static inline var DUST = 0x7e6e60;
    
    // Utility function to get all colors as an array
    public static function getAllColors():Array<Int> {
        return [
            BLACK, DARK_GRAY, GRAY, LIGHT_GRAY, SILVER, LIGHT_SILVER, WARM_GRAY, PALE_GRAY,
            DARK_BLUE, BLUE, LIGHT_BLUE, CYAN, PALE_BLUE, SKY_BLUE, TEAL, DEEP_TEAL,
            DARK_GREEN, GREEN, LIGHT_GREEN, LIME, PALE_GREEN, YELLOW_GREEN, MINT, SAGE,
            DARK_BROWN, BROWN, LIGHT_BROWN, TAN, PEACH, CORAL, PINK, PALE_PINK,
            DARK_RED, RED, BRIGHT_RED, ORANGE_RED, ORANGE, LIGHT_ORANGE, YELLOW, PALE_YELLOW,
            DARK_PURPLE, PURPLE, LIGHT_PURPLE, MAGENTA, PINK_PURPLE, LAVENDER, PALE_LAVENDER, WHITE,
            INK, SHADOW, MID_TONE, HIGHLIGHT, CREAM, BONE, SAND, DUST
        ];
    }
    
    // Get a color by index (0-63)
    public static function getColorByIndex(index:Int):Int {
        var colors = getAllColors();
        if (index < 0 || index >= colors.length) return BLACK;
        return colors[index];
    }
}
class TestMain extends hxd.App {
    static function main() {
        new TestMain();
    }
    
    override function init() {
        var tf = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
        tf.text = "Hello HashLink!";
        tf.x = 100;
        tf.y = 100;
    }
}
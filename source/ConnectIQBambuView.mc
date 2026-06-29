import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class ConnectIQBambuView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Graphics.Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        View.onUpdate(dc);
    }

    function onHide() as Void {
    }
}

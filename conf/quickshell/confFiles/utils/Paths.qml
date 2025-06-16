pragma Singleton

import Quickshell
import Quickshell.Io
import Qt.labs.platform

Singleton {
    id: root

    readonly property url home: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
    readonly property url pictures: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]

    readonly property url data: `${home}/.config/quickshell/data`
    readonly property url state: `${home}/.config/quickshell/state`
    readonly property url cache: `${home}/.config/quickshell/cache`

    readonly property url imagecache: `${cache}/imagecache`

    function mkdir(path: url): void {
        mkdirProc.path = path.toString().replace("file://", "");
        mkdirProc.startDetached();
    }

    Process {
        id: mkdirProc

        property string path

        command: ["mkdir", "-p", path]
    }
}

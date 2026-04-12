import QtQuick

Item {
    id: root

    required property var points

    property real barWidth: 18
    property real barSpacing: 10
    property real barRadius: 10
    property real maxValue: 1000
    property real smoothing: 0.35
    property real visualizerOpacity: 0.9
    property bool mirror: true
    property color barColor: "white"

    property var smoothedPoints: []

    opacity: visualizerOpacity

    onPointsChanged: {
        const next = points || [];
        if (smoothedPoints.length !== next.length) {
            smoothedPoints = next.slice();
            return;
        }

        const factor = Math.max(0, Math.min(1, smoothing));
        const updated = [];
        for (let i = 0; i < next.length; ++i) {
            const previous = typeof smoothedPoints[i] === "number" ? smoothedPoints[i] : 0;
            updated.push(previous + ((next[i] || 0) - previous) * factor);
        }
        smoothedPoints = updated;
    }

    function clamp(value, minValue, maxValue) {
        return Math.max(minValue, Math.min(maxValue, value));
    }

    readonly property int barCount: smoothedPoints.length
    readonly property real slotWidth: Math.max(1, barWidth + barSpacing)
    readonly property real totalBarsWidth: barCount > 0 ? (barCount * barWidth) + ((barCount - 1) * barSpacing) : 0
    readonly property real startX: Math.max(0, (width - totalBarsWidth) / 2)
    readonly property real centerLine: mirror ? height / 2 : height
    readonly property real halfHeight: mirror ? height / 2 : height

    Repeater {
        model: root.barCount

        delegate: Item {
            required property int index

            readonly property real normalized: root.clamp((root.smoothedPoints[index] || 0) / Math.max(1, root.maxValue), 0, 1)
            readonly property real currentHeight: Math.max(2, normalized * root.halfHeight)

            x: root.startX + (index * root.slotWidth)
            width: root.barWidth
            height: root.height

            Rectangle {
                visible: root.mirror
                x: 0
                y: root.centerLine - parent.currentHeight
                width: root.barWidth
                height: parent.currentHeight
                radius: Math.min(root.barRadius, width / 2)
                color: root.barColor
            }

            Rectangle {
                x: 0
                y: root.mirror ? root.centerLine : root.height - parent.currentHeight
                width: root.barWidth
                height: parent.currentHeight
                radius: Math.min(root.barRadius, width / 2)
                color: root.barColor
            }
        }
    }
}

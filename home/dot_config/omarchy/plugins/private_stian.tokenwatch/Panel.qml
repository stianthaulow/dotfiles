import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Subscription usage from the tokenwatch poller, which the home agent feeds
// from CLIProxyAPI's passive rate-limit snapshot. This widget only reads the
// poller: it never talks to Anthropic, OpenAI or the proxy.
//
// URL and read token come from ~/.config/tokenwatch/widget.json (untracked):
//   { "url": "https://tokenwatch.thaulow.dev/usage", "token": "..." }
Panel {
  id: root
  moduleName: "stian.tokenwatch"
  ipcTarget: "stian.tokenwatch"
  manageIpc: false

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color urgent: bar ? bar.urgent : Color.urgent
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property color track: Style.selectedFillFor(foreground, Color.accent)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

  property var endpoint: ({ url: "", token: "" })
  property var blob: null
  property string fetchError: ""
  property double fetchedAtMs: 0
  property double nowMs: Date.now()

  // Same order CLIProxyAPI burns them in: higher priority first, accounts
  // without one (other providers) last, ties in config order.
  readonly property var accounts: {
    var list = blob && blob.accounts ? blob.accounts.slice() : []
    function prio(a) {
      var n = Number(a.priority)
      return a.priority === null || a.priority === undefined || !isFinite(n) ? -Infinity : n
    }
    var indexed = list.map(function(a, i) { return { a: a, i: i } })
    indexed.sort(function(x, y) { return prio(y.a) - prio(x.a) || x.i - y.i })
    return indexed.map(function(e) { return e.a })
  }
  readonly property var activeAccount: {
    for (var i = 0; i < accounts.length; i++) if (accounts[i].active) return accounts[i]
    return null
  }
  readonly property bool alarming: !!activeAccount && bindingPercent(activeAccount) >= 90
  readonly property bool feedStale: fetchError !== "" || (accounts.length > 0 && accounts.every(function(a) { return a.status === "stale" }))

  function clamp(v, lo, hi) { return Math.max(lo, Math.min(hi, v)) }

  function percentOf(g) {
    var n = g ? Number(g.percent) : NaN
    return isFinite(n) ? n : -1
  }

  // The fuller window is the one that stops the next prompt.
  function bindingPercent(a) {
    return Math.max(percentOf(a.session), percentOf(a.weekly))
  }

  function resetMs(g) {
    if (!g || !g.resets_at) return -1
    var ms = new Date(g.resets_at).getTime()
    return isFinite(ms) ? ms - nowMs : -1
  }

  function formatDuration(ms) {
    if (!(ms > 0)) return "now"
    var minutes = Math.floor(ms / 60000)
    var hours = Math.floor(minutes / 60)
    var days = Math.floor(hours / 24)
    if (days > 0) return days + "d " + (hours % 24) + "h"
    if (hours > 0) return hours + "h " + (minutes % 60) + "m"
    return Math.max(1, minutes) + "m"
  }

  function ageText(iso) {
    var ms = new Date(iso || "").getTime()
    if (!isFinite(ms)) return ""
    var age = nowMs - ms
    return age < 90000 ? "just now" : formatDuration(age) + " ago"
  }

  function statusText(a) {
    if (a.status === "reauth") return "Sign in again in CLIProxyAPI"
    if (a.status === "stale") return "Stale · data " + ageText(a.data_at)
    if (a.active) return "In use · data " + ageText(a.data_at)
    return "Data " + ageText(a.data_at)
  }

  function footerText() {
    if (fetchError !== "") return fetchError + (fetchedAtMs > 0 ? " · last fetch " + ageText(new Date(fetchedAtMs).toISOString()) : "")
    if (!blob) return "Loading…"
    return "Updated " + ageText(blob.updated_at)
  }

  function refresh() {
    if (endpoint.url === "" || endpoint.token === "") {
      fetchError = "Missing ~/.config/tokenwatch/widget.json"
      return
    }
    var xhr = new XMLHttpRequest()
    xhr.onreadystatechange = function() {
      if (xhr.readyState !== XMLHttpRequest.DONE) return
      if (xhr.status === 200) {
        try {
          root.blob = JSON.parse(xhr.responseText)
          root.fetchError = ""
          root.fetchedAtMs = Date.now()
        } catch (e) {
          root.fetchError = "Bad response from tokenwatch"
        }
      } else {
        root.fetchError = xhr.status === 0 ? "Tokenwatch unreachable" : "Tokenwatch HTTP " + xhr.status
      }
      root.nowMs = Date.now()
    }
    xhr.open("GET", endpoint.url)
    xhr.setRequestHeader("Authorization", "Bearer " + endpoint.token)
    xhr.send()
  }

  property FileView endpointFile: FileView {
    path: Quickshell.env("HOME") + "/.config/tokenwatch/widget.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      try {
        var parsed = JSON.parse(text())
        root.endpoint = { url: String(parsed.url || ""), token: String(parsed.token || "") }
      } catch (e) {
        root.endpoint = { url: "", token: "" }
      }
      root.refresh()
    }
    onLoadFailed: {
      root.endpoint = { url: "", token: "" }
      root.refresh()
    }
  }

  Timer {
    interval: Math.max(30, Number(root.setting("refreshIntervalSec", 60))) * 1000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  Timer {
    interval: 30000
    running: root.opened
    repeat: true
    onTriggered: root.nowMs = Date.now()
  }

  onOpenedChanged: if (opened) {
    nowMs = Date.now()
    refresh()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  IpcHandler {
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function toggle(): void { root.toggle() }
    function refresh(): string { root.refresh(); return "ok" }
  }

  // WidgetButton, not BarIconButton: the percentage needs a width that follows
  // the text instead of a fixed icon slot.
  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.activeAccount && root.percentOf(root.activeAccount.session) >= 0
      ? "󱚣 " + Math.round(root.percentOf(root.activeAccount.session)) + "%"
      : "󱚣"
    active: root.alarming
    dimmed: root.feedStale
    tooltipText: ""
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.MiddleButton) root.refresh()
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(column.implicitHeight, Style.space(720))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent

      onMoveRequested: function(dx, dy) {
        if (dy !== 0)
          flick.contentY = root.clamp(flick.contentY + dy * Style.space(56), 0,
                                      Math.max(0, flick.contentHeight - flick.height))
      }
      onActivateRequested: root.refresh()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) { if (t === "r" || t === "R") root.refresh() }

      Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: column.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        interactive: contentHeight > height
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        Column {
          id: column
          width: flick.width
          spacing: Style.space(12)

          PanelSectionHeader {
            text: "SUBSCRIPTIONS"
            foreground: root.foreground
            fontFamily: root.fontFamily
          }

          Repeater {
            model: root.accounts

            AccountBlock {
              required property var modelData
              required property int index
              width: column.width
              account: modelData
              first: index === 0
            }
          }

          Text {
            textFormat: Text.PlainText
            width: parent.width
            topPadding: Style.space(2)
            text: root.footerText()
            color: root.fetchError !== "" ? root.urgent : root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
          }
        }
      }
    }
  }

  // One subscription: name and state, then session and weekly windows.
  component AccountBlock: Column {
    id: block
    property var account: null
    property bool first: false

    spacing: Style.space(8)

    PanelSeparator {
      visible: !block.first
      foreground: root.foreground
    }

    Item {
      width: parent.width
      implicitHeight: Math.max(nameRow.implicitHeight, stateText.implicitHeight)

      Row {
        id: nameRow
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(8)

        Rectangle {
          width: Style.space(8)
          height: width
          radius: width / 2
          anchors.verticalCenter: parent.verticalCenter
          color: block.account ? block.account.color : root.foreground
        }

        Text {
          textFormat: Text.PlainText
          text: block.account ? block.account.label : ""
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          font.bold: !!block.account && block.account.active
        }
      }

      Text {
        id: stateText
        textFormat: Text.PlainText
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: nameRow.right
        anchors.leftMargin: Style.space(8)
        horizontalAlignment: Text.AlignRight
        elide: Text.ElideLeft
        text: block.account ? root.statusText(block.account) : ""
        color: block.account && block.account.status === "reauth" ? root.urgent : root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }
    }

    LimitRow {
      width: parent.width
      title: "Session"
      gauge: block.account ? block.account.session : null
    }

    LimitRow {
      width: parent.width
      title: "Weekly"
      gauge: block.account ? block.account.weekly : null
    }
  }

  // Label, percentage and reset countdown on one line, meter under it.
  component LimitRow: Column {
    id: limitRow
    property string title: ""
    property var gauge: null

    readonly property real percent: root.percentOf(gauge)
    readonly property bool alarming: percent >= 90

    spacing: Style.space(4)

    Item {
      width: parent.width
      implicitHeight: limitLabel.implicitHeight

      Text {
        id: limitLabel
        textFormat: Text.PlainText
        anchors.left: parent.left
        text: {
          var ms = root.resetMs(limitRow.gauge)
          return limitRow.title + (ms > 0 ? " · resets in " + root.formatDuration(ms) : "")
        }
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }

      Text {
        textFormat: Text.PlainText
        anchors.right: parent.right
        text: limitRow.percent >= 0 ? Math.round(limitRow.percent) + "%" : "—"
        color: limitRow.alarming ? root.urgent : root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }
    }

    Item {
      width: parent.width
      implicitHeight: Math.max(Style.space(4), Math.round(Style.spacing.controlHeight * 0.14))

      Rectangle {
        id: meterTrack
        anchors.fill: parent
        radius: height / 2
        color: root.track
      }

      Rectangle {
        anchors.left: meterTrack.left
        anchors.verticalCenter: meterTrack.verticalCenter
        height: meterTrack.height
        radius: meterTrack.radius
        width: meterTrack.width * root.clamp(limitRow.percent / 100, 0, 1)
        color: limitRow.alarming ? root.urgent : root.foreground

        Behavior on width {
          NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
        }
      }
    }
  }
}

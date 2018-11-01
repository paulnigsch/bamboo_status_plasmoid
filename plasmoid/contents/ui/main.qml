/*
 */

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras

import Qt.labs.settings 1.0

import "../js/BLogic.js" as BLogic

Item {

  id: app

  Component.onCompleted: {
    console.log("config data > ", plasmoid.configuration.keys(), "<");
    print(plasmoid.configuration.keys());
    BLogic.updateData()
  }

  // Initial size of the window in gridUnits
  width: units.gridUnit * 28
  height: units.gridUnit * 20

  ListModel {
    id: model
  }

  //////////////////////////////////////////////
  // visual area

  // A button to force the refresh
  property int headingHeight : 40

  RowLayout {
    x: 0
    y: 0

    id: layout
    spacing: 6
    width: parent.width
    height:  headingHeight

    Rectangle {
        color: Qt.rgba(0,0,0,0)
        Layout.minimumWidth: 200
        Layout.fillWidth: true

        height: parent.height

        Text {
          anchors.fill: parent

          id: heading_text
          text: plan_name
          color: "white"
          font.weight: Font.Bold 
          font.pixelSize: 20

          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
        }
    } 

    Button {
      id: 'refreshButton'
      text: 'refresh'
      onClicked: BLogic.updateData()

      height: parent.height
      Layout.minimumWidth: 60
      Layout.preferredWidth: 80
      Layout.fillWidth: false
    }
    
  }

  BusyIndicator {
    id: busy_indicator
    width: 40
    height: 40
    visible: true
    running: false

    /*
    style: BusyIndicatorStyle {
        indicator: Image {
            visible: true
            source: "spinner.png"
            RotationAnimator on rotation {
                running: control.running
                loops: Animation.Infinite
                duration: 2000
                from: 0 ; to: 360
            }
        }
    }
    */

    MouseArea {
      anchors.fill: parent
      onClicked: BLogic.updateData()
    }
  }

  Item {
    width: parent.width
    height: parent.height - 20
    y: headingHeight + 4 

    Rectangle {
      id: startscreen
      anchors.fill: parent

      color: "lightblue"
      visible: true
      opacity: 0.5

      property string screentext: "loading"

      Text {
        text: parent.screentext
        anchors.centerIn : parent
        font.pixelSize: 30
      }
    }

    Rectangle {
      id: mainwindow
      width: parent.width
      height: parent.height - 30
      visible: false

      Component {
        id: deleg

        Item {
          width: parent.width
          height: 80

          state: buildState 
          states : [
            State  {name : "Successful";
              PropertyChanges { target: rect ; color: Qt.rgba(0, 255, 0, 0.5) }
              },

            State  {name : "Building" ;
              PropertyChanges { target: rect ; color: Qt.rgba(1, 255, 1, 0.5) }
            },
            State  {name : "QUEUED" ;
              PropertyChanges { target: rect ; color: 'lightblue' }
            },
            State  {name : "Failed";
              PropertyChanges { target: rect ; color: Qt.rgba(255, 0, 0, 0.5) }
             },
            State  {name : "updating";
              PropertyChanges { target: rect ; color: Qt.rgba(0, 0, 0,  0.5) }
             }
          ]


          transitions: [
            Transition {
                from: "updating"
                to: "*"
                ColorAnimation { target: rect; duration: 500}
            }
          ]


          MouseArea {
            anchors.fill: parent
            onClicked: function () {
              var build_result_url = app.bamboo_base_url + '/browse/' + resultKey;
              Qt.openUrlExternally(build_result_url);
            }
          }

          Rectangle {
            Column {
              padding: 5
              Text { clip: true; text: '<b>Name:</b> ' + name }
              Text { clip: true; text: '<b>Status:</b> ' + buildState }
              Text { clip: true; text: '<b>plankey:</b> ' + planKey }
              Text { clip: true; text: '<a href=' + link + '>' + link + '</a>'; onLinkActivated: Qt.openUrlExternally(link) }
            }

/*
            color:  {
              if ( buildState === "Successful" ) {
                return Qt.rgba(0, 255, 0, 0.5);
              } else if ( buildState === "BUILDING" ) { 
                return "lightblue";
              } else if ( buildState === "QUEUED" ) { 
                return "lightblue";
              }  else if (buildState === "Failed" ) {
                return Qt.rgba(255, 0, 0, 0.5)
              } 
              return "white"
            }*/

            width: parent.width
            height: parent.height
            id: rect
            radius: 5
            border.color: "#333"
            border.width: 1

          }
        }
      }

      ListView {
        id: listview
        spacing: 2
        clip: true
        width: parent.width - 4 
        height: parent.height - 4 
        anchors.centerIn: parent
        model: model
        delegate: deleg
        highlight: Rectangle { color: "lightsteelblue"; radius: 5 }
        focus: true


      }
    }

    Rectangle {
      id: errorindicator
      anchors.fill: parent

      visible: false
      color: Qt.rgba(255,0, 0, 0.2) 

      Text {
        id: errorindicator_text
        anchors.centerIn : parent
        text: "network error"
        font.pixelSize: 30

      }
    }
  }

  //////////////////////////////////////////////
  // refresh timer
  Timer {
    interval: 1000 * 60 * 5; running: true; repeat: true
    onTriggered: BLogic.updateData()
  }

  //////////////////////////////////////////////
  // Overlay everything with a decorative, large, translucent icon
  PlasmaCore.IconItem {

    // We use an anchor layout and dpi-corrected sizing
    width: units.iconSizes.large * 4
    height: width
    anchors {
      left: parent.left
      bottom: parent.bottom
    }

    source: "akregator"
    opacity: 0.1
  }


  //////////////////////////////////////////////
  // State handling
  states: [
    State {
      name: "startup" 
      PropertyChanges { target: errorindicator ; visible: false }
      PropertyChanges { target: mainwindow ; visible: false }
      PropertyChanges { target: startscreen ; visible: true }
    },
    State {
      name: "networkerror"
      PropertyChanges { target: errorindicator ; visible: true }
      PropertyChanges { target: mainwindow ; visible: false }
      PropertyChanges { target: startscreen ; visible: false }
    },
    State {
      name: "ok"
      PropertyChanges { target: errorindicator ; visible: false }
      PropertyChanges { target: mainwindow ; visible: true }
      PropertyChanges { target: startscreen ; visible: false }
    }
  ]
  state: "startup"

  //////////////////////////////////////////////
  // configurations
  property string plan_name: plasmoid.configuration.name
  property string bamboo_base_url: plasmoid.configuration.url
  property string bamboocreds: plasmoid.configuration.credentials
  property string project_key: plasmoid.configuration.project_key
  property string plan_key: plasmoid.configuration.plan_key
}

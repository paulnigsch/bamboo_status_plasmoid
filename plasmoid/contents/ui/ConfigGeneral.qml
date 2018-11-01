/*
    Copyright (c) 2016 Carlos López Sánchez <musikolo{AT}hotmail[DOT]com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import QtQuick.Layouts 1.0 as QtLayouts
import QtQuick.Controls 1.0 as QtControls

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    id: iconsPage
    width: childrenRect.width
    height: childrenRect.height
    implicitWidth: pageColumn.implicitWidth
    implicitHeight: pageColumn.implicitHeight


    property alias cfg_url: url_field.text
    property alias cfg_name: name_field.text
    
    property alias cfg_project_key: project_field.text
    property alias cfg_plan_key: plan_field.text
    property alias cfg_credentials: credentials_field.text

    property int defaultLeftMargin : 00

    QtLayouts.ColumnLayout {
        id: pageColumn

        PlasmaExtras.Heading {
            text: i18nc("general stuff", "Actions")
            color: syspal.text
            level: 2
        }

        Column {
            spacing: 5


            Column {
                QtControls.Label {
                    id: nameLabel
                    text: i18n("Name")
                }
                QtControls.TextField {
                    id: name_field
                    anchors.left: parent.left
                    anchors.leftMargin: defaultLeftMargin
                    text: i18n("Name")
                }
            }

            Column {
                QtControls.Label {
                    id: urlLabel
                    text: i18n("url ")
                }
                QtControls.TextField {
                    id: url_field
                    anchors.left: parent.left
                    anchors.leftMargin: defaultLeftMargin
                    text: i18n("Enabled")
                }
            }


            Column {
                QtControls.Label {
                    id: credentials_label
                    text: i18n("credential")
                }
                QtControls.TextField {
                    id: credentials_field
                    anchors.left: parent.left
                    anchors.leftMargin: defaultLeftMargin
                    text: i18n("Enabled")
                }
            }

            Column {
                QtControls.Label {
                    id: project_label
                    text: i18n("project")
                }
                QtControls.TextField {
                    id: project_field
                    anchors.left: parent.left
                    anchors.leftMargin: defaultLeftMargin
                    text: i18n("Enabled")
                }
            }

             Column {
                QtControls.Label {
                    id: plan_label
                    text: i18n("plan")
                }
                QtControls.TextField {
                    id: plan_field
                    anchors.left: parent.left
                    anchors.leftMargin: defaultLeftMargin
                    text: i18n("Enabled")
                }
            }




        }
    }
}

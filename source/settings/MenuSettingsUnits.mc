// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Pilot ICAO/ISA Altimeter (Pilot Altimeter)
// Copyright (C) 2018 Cedric Dufour <http://cedric.dufour.name>
//
// Pilot ICAO/ISA Altimeter (Pilot Altimeter) is free software:
// you can redistribute it and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation, Version 3.
//
// Pilot ICAO/ISA Altimeter (Pilot Altimeter) is distributed in the hope that it
// will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// See the GNU General Public License for more details.
//
// SPDX-License-Identifier: GPL-3.0
// License-Filename: LICENSE/GPL-3.0.txt

using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MenuSettingsUnits extends Ui.Menu {

  //
  // FUNCTIONS: Ui.Menu (override/implement)
  //

  function initialize() {
    Menu.initialize();
    Menu.setTitle(Ui.loadResource(Rez.Strings.titleSettingsUnits));
    Menu.addItem(Ui.loadResource(Rez.Strings.titleUnitElevation), :menuUnitElevation);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleUnitPressure), :menuUnitPressure);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleUnitTemperature), :menuUnitTemperature);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleUnitTimeUTC), :menuUnitTimeUTC);
  }

}

class MenuDelegateSettingsUnits extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :menuUnitElevation) {
      //Sys.println("DEBUG: MenuDelegateSettingsUnits.onMenuItem(:menuUnitElevation)");
      Ui.pushView(new PickerUnitElevation(), new PickerDelegateUnitElevation(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuUnitPressure) {
      //Sys.println("DEBUG: MenuDelegateSettingsUnits.onMenuItem(:menuUnitPressure)");
      Ui.pushView(new PickerUnitPressure(), new PickerDelegateUnitPressure(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuUnitTemperature) {
      //Sys.println("DEBUG: MenuDelegateSettingsUnits.onMenuItem(:menuUnitTemperature)");
      Ui.pushView(new PickerUnitTemperature(), new PickerDelegateUnitTemperature(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuUnitTimeUTC) {
      //Sys.println("DEBUG: MenuDelegateSettingsUnits.onMenuItem(:menuUnitTimeUTC)");
      Ui.pushView(new PickerUnitTimeUTC(), new PickerDelegateUnitTimeUTC(), Ui.SLIDE_IMMEDIATE);
    }
  }

}

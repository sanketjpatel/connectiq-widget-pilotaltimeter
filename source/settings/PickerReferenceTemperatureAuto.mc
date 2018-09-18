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

using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

class PickerReferenceTemperatureAuto extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    // Get property
    var bReferenceTemperatureAuto = App.Properties.getValue("userReferenceTemperatureAuto");

    // Initialize picker
    var oFactory = new PickerFactoryDictionary([true, false], [Ui.loadResource(Rez.Strings.valueAuto), Ui.loadResource(Rez.Strings.valueSet)], null);
    Picker.initialize({
      :title => new Ui.Text({ :text => Ui.loadResource(Rez.Strings.titleReferenceTemperatureAuto), :font => Gfx.FONT_TINY, :locX=>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color => Gfx.COLOR_BLUE }),
      :pattern => [ oFactory ],
      :defaults => [ oFactory.indexOfKey(bReferenceTemperatureAuto) ]
    });
  }

}

class PickerReferenceTemperatureAutoDelegate extends Ui.PickerDelegate {

  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize() {
    PickerDelegate.initialize();
  }

  function onAccept(_amValues) {
    // Set property and exit
    App.Properties.setValue("userReferenceTemperatureAuto", _amValues[0]);
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

}

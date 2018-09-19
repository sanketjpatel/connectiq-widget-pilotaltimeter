// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Pilot ICAO/ISA Altimeter (PilotAltimeter)
// Copyright (C) 2018 Cedric Dufour <http://cedric.dufour.name>
//
// Pilot ICAO/ISA Altimeter (PilotAltimeter) is free software:
// you can redistribute it and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation, Version 3.
//
// Pilot ICAO/ISA Altimeter (PilotAltimeter) is distributed in the hope that it
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

class PickerReferenceTemperature extends PickerGenericTemperature {

  //
  // FUNCTIONS: PickerGenericTemperature (override/implement)
  //

  function initialize() {
    PickerGenericTemperature.initialize(Ui.loadResource(Rez.Strings.titleReferenceTemperature), $.PA_oAltimeter.fTemperatureActual-273.15f, $.PA_oSettings.iUnitTemperature);  // ... altimeter internals are °K
  }

}

class PickerReferenceTemperatureDelegate extends Ui.PickerDelegate {

  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize() {
    PickerDelegate.initialize();
  }

  function onAccept(_amValues) {
    // Set property and exit
    var fValue = PickerGenericTemperature.getValue(_amValues, $.PA_oSettings.iUnitTemperature)+273.15f;  // ... altimeter internals are °K
    fValue -= $.PA_oAltimeter.fTemperatureISA;
    App.Properties.setValue("userReferenceTemperatureISAOffset", fValue);
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

}

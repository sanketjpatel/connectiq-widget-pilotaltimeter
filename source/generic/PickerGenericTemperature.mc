// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Generic ConnectIQ Helpers/Resources (CIQ Helpers)
// Copyright (C) 2017-2018 Cedric Dufour <http://cedric.dufour.name>
//
// Generic ConnectIQ Helpers/Resources (CIQ Helpers) is free software:
// you can redistribute it and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation, Version 3.
//
// Generic ConnectIQ Helpers/Resources (CIQ Helpers) is distributed in the hope
// that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// See the GNU General Public License for more details.
//
// SPDX-License-Identifier: GPL-3.0
// License-Filename: LICENSE/GPL-3.0.txt

using Toybox.Graphics as Gfx;
using Toybox.Lang;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class PickerGenericTemperature extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize(_sTitle, _fValue, _iUnit) {
    // Input validation
    // ... unit
    if(_iUnit == null or _iUnit < 0) {
      var oDeviceSettings = Sys.getDeviceSettings();
      if(oDeviceSettings has :temperatureUnits and oDeviceSettings.temperatureUnits != null) {
        _iUnit = oDeviceSettings.temperatureUnits;
      }
      else {
        _iUnit = Sys.UNIT_METRIC;
      }
    }
    // ... value
    if(_fValue == null) {
      _fValue = 0.0f;
    }

    // Use user-specified temperature unit (NB: metric units are always used internally)
    var sUnit;
    if(_iUnit == Sys.UNIT_STATUTE) {
      sUnit = "°F";
      _fValue = _fValue*1.8f+32.0f;  // ... from celsius
    }
    else {
      sUnit = "°C";
    }

    // Initialize picker
    var oFactory = new PickerFactoryNumber(-99, _iUnit == Sys.UNIT_STATUTE ? 199 : 99, null);
    Picker.initialize({
      :title => new Ui.Text({ :text => Lang.format("$1$ [$2$]", [_sTitle, sUnit]), :font => Gfx.FONT_TINY, :locX=>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color => Gfx.COLOR_BLUE }),
      :pattern => [ oFactory ],
      :defaults => [ oFactory.indexOf(_fValue.toNumber()) ]
    });
  }


  //
  // FUNCTIONS: self
  //

  function getValue(_amValues, _iUnit) {
    // Input validation
    // ... unit
    if(_iUnit == null or _iUnit < 0) {
      var oDeviceSettings = Sys.getDeviceSettings();
      if(oDeviceSettings has :temperatureUnits and oDeviceSettings.temperatureUnits != null) {
        _iUnit = oDeviceSettings.temperatureUnits;
      }
      else {
        _iUnit = Sys.UNIT_METRIC;
      }
    }

    // Assemble components
    var fValue = _amValues[0].toFloat();

    // Use user-specified temperature unit (NB: metric units are always used internally)
    if(_iUnit == Sys.UNIT_STATUTE) {
      fValue = (fValue-32.0f)/1.8f;  // ... to celsius
    }

    // Return value
    return fValue;
  }
}

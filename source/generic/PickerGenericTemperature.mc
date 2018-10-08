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
    var iMaxSignificant;
    if(_iUnit == Sys.UNIT_STATUTE) {
      sUnit = "°F";
      iMaxSignificant = 19;
      _fValue = _fValue*18.0f+320.0f;  // ... from celsius
      if(_fValue > 1999.0f) {
        _fValue = 1999.0f;
      }
      else if(_fValue < -1999.0f) {
        _fValue = -1999.0f;
      }
    }
    else {
      sUnit = "°C";
      iMaxSignificant = 9;
      _fValue = _fValue*10.0f;
      if(_fValue > 999.0f) {
        _fValue = 999.0f;
      }
      else if(_fValue < -999.0f) {
        _fValue = -999.0f;
      }
    }

    // Split components
    var amValues = new [4];
    amValues[0] = _fValue < 0.0f ? 0 : 1;
    _fValue = _fValue.abs() + 0.05f;
    amValues[3] = _fValue.toNumber() % 10;
    _fValue = _fValue / 10.0f;
    amValues[2] = _fValue.toNumber() % 10;
    _fValue = _fValue / 10.0f;
    amValues[1] = _fValue.toNumber();

    // Initialize picker
    Picker.initialize({
      :title => new Ui.Text({ :text => Lang.format("$1$ [$2$]", [_sTitle, sUnit]), :font => Gfx.FONT_TINY, :locX=>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color => Gfx.COLOR_BLUE }),
      :pattern => [ new PickerFactoryDictionary([-1, 1], ["-", "+"], null),
                    new PickerFactoryNumber(0, iMaxSignificant, null),
                    new PickerFactoryNumber(0, 9, { :langFormat => "$1$." }),
                    new PickerFactoryNumber(0, 9, null) ],
      :defaults => amValues
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
    var fValue = _amValues[1]*100.0f + _amValues[2]*10.0f + _amValues[3];
    fValue *= _amValues[0];

    // Use user-specified temperature unit (NB: metric units are always used internally)
    if(_iUnit == Sys.UNIT_STATUTE) {
      fValue = (fValue-320.0f)/18.0f;  // ... to celsius
    }
    else {
      fValue /= 10.0f;
    }

    // Return value
    return fValue;
  }
}

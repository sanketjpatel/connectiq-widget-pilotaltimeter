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
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

//
// GLOBALS
//

// Current view index and labels
var PA_iViewIndex = 0;
var PA_sViewLabelTop = null;
var PA_sViewLabelBottom = null;


//
// CLASS
//

class PA_View extends Ui.View {

  //
  // CONSTANTS
  //

  private const NOVALUE_BLANK = "";
  private const NOVALUE_LEN3 = "---";


  //
  // VARIABLES
  //

  // Display mode (internal)
  private var bShow;

  // Resources
  // ... drawable
  private var oRezDrawable;
  // ... header
  private var oRezValueDate;
  // ... label
  private var oRezLabelTop;
  // ... fields
  private var oRezValueTop;
  private var oRezValueBottom;
  // ... label
  private var oRezLabelBottom;
  // ... footer
  private var oRezValueTime;


  //
  // FUNCTIONS: Ui.View (override/implement)
  //

  function initialize() {
    View.initialize();

    // Display mode (internal)
    self.bShow = false;
  }

  function onLayout(_oDC) {
    View.setLayout(Rez.Layouts.PA_Layout(_oDC));

    // Load resources
    // ... drawable
    self.oRezDrawable = View.findDrawableById("PA_Drawable");
    // ... header
    self.oRezValueDate = View.findDrawableById("valueDate");
    // ... label
    self.oRezLabelTop = View.findDrawableById("labelTop");
    // ... fields
    self.oRezValueTop = View.findDrawableById("valueTop");
    self.oRezValueBottom = View.findDrawableById("valueBottom");
    // ... label
    self.oRezLabelBottom = View.findDrawableById("labelBottom");
    // ... footer
    self.oRezValueTime = View.findDrawableById("valueTime");

    // Done
    return true;
  }

  function onShow() {
    //Sys.println("DEBUG: PA_View.onShow()");

    // Reload settings (which may have been changed by user)
    self.reloadSettings();

    // Set colors
    var iColorText = $.PA_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    // ... background
    self.oRezDrawable.setColorBackground($.PA_oSettings.iGeneralBackgroundColor);
    // ... date
    self.oRezValueDate.setColor(iColorText);
    // ... fields
    self.oRezValueTop.setColor(iColorText);
    self.oRezValueBottom.setColor(iColorText);
    // ... time
    self.oRezValueTime.setColor(iColorText);

    // Done
    self.bShow = true;
    $.PA_oCurrentView = self;
    return true;
  }

  function onUpdate(_oDC) {
    //Sys.println("DEBUG: PA_View.onUpdate()");

    // Update layout
    self.updateLayout();
    View.onUpdate(_oDC);

    // Done
    return true;
  }

  function onHide() {
    //Sys.println("DEBUG: PA_View.onHide()");
    $.PA_oCurrentView = null;
    self.bShow = false;
  }


  //
  // FUNCTIONS: self
  //

  function reloadSettings() {
    //Sys.println("DEBUG: PA_View.reloadSettings()");

    // Update application state
    App.getApp().updateApp();
  }

  function updateUi() {
    //Sys.println("DEBUG: PA_View.updateUi()");

    // Request UI update
    if(self.bShow) {
      Ui.requestUpdate();
    }
  }

  function updateLayout() {
    //Sys.println("DEBUG: PA_View.updateLayout()");

    // Set header/footer values
    var iColorText = $.PA_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    var oTimeNow = Time.now();

    // ... date
    var oDateInfo = $.PA_oSettings.bUnitTimeUTC ? Gregorian.utcInfo(oTimeNow, Time.FORMAT_MEDIUM) : Gregorian.info(oTimeNow, Time.FORMAT_MEDIUM);
    self.oRezValueDate.setText(Lang.format("$1$ $2$", [oDateInfo.month, oDateInfo.day.format("%d")]));

    // ... time
    var oTimeInfo = $.PA_oSettings.bUnitTimeUTC ? Gregorian.utcInfo(oTimeNow, Time.FORMAT_SHORT) : Gregorian.info(oTimeNow, Time.FORMAT_SHORT);
    self.oRezValueTime.setText(Lang.format("$1$:$2$ $3$", [oTimeInfo.hour.format("%d"), oTimeInfo.min.format("%02d"), $.PA_oSettings.sUnitTime]));

    // Set field values
    if($.PA_iViewIndex == 0) {
      // ... actual altitude
      if($.PA_sViewLabelTop == null) {
        $.PA_sViewLabelTop = Ui.loadResource(Rez.Strings.labelAltitudeActual);
      }
      self.oRezLabelTop.setText($.PA_sViewLabelTop);
      if($.PA_oAltimeter.fAltitudeActual != null) {
        self.oRezValueTop.setText(self.stringElevation($.PA_oAltimeter.fAltitudeActual, false));
      }
      else {
        self.oRezValueTop.setText(self.NOVALUE_LEN3);
      }
      // ... QNH
      if($.PA_sViewLabelBottom == null) {
        $.PA_sViewLabelBottom = Ui.loadResource(Rez.Strings.labelPressureQNH);
      }
      self.oRezLabelBottom.setText($.PA_sViewLabelBottom);
      if($.PA_oAltimeter.fQNH != null) {
        self.oRezValueBottom.setText(self.stringPressure($.PA_oAltimeter.fQNH));
      }
      else {
        self.oRezValueBottom.setText(self.NOVALUE_LEN3);
      }
    }
    else if($.PA_iViewIndex == 1) {
      // ... flight level
      if($.PA_sViewLabelTop == null) {
        $.PA_sViewLabelTop = Ui.loadResource(Rez.Strings.labelAltitudeFL);
      }
      self.oRezLabelTop.setText($.PA_sViewLabelTop);
      if($.PA_oAltimeter.fAltitudeActual != null) {
        self.oRezValueTop.setText(self.stringFlightLevel($.PA_oAltimeter.fAltitudeISA, false));
      }
      else {
        self.oRezValueTop.setText(self.NOVALUE_LEN3);
      }
      // ... standard altitude (ISA)
      if($.PA_sViewLabelBottom == null) {
        $.PA_sViewLabelBottom = Ui.loadResource(Rez.Strings.labelAltitudeISA);
      }
      self.oRezLabelBottom.setText($.PA_sViewLabelBottom);
      if($.PA_oAltimeter.fAltitudeISA != null) {
        self.oRezValueBottom.setText(self.stringFlightLevel($.PA_oAltimeter.fAltitudeISA, true));
      }
      else {
        self.oRezValueBottom.setText(self.NOVALUE_LEN3);
      }
    }
    else if($.PA_iViewIndex == 2) {
      // ... height
      if($.PA_sViewLabelTop == null) {
        $.PA_sViewLabelTop = Ui.loadResource(Rez.Strings.labelHeight);
      }
      self.oRezLabelTop.setText($.PA_sViewLabelTop);
      if($.PA_oAltimeter.fAltitudeActual != null and $.PA_oSettings.fReferenceElevation != null) {
        self.oRezValueTop.setText(self.stringElevation($.PA_oAltimeter.fAltitudeActual-$.PA_oSettings.fReferenceElevation, true));
      }
      else {
        self.oRezValueTop.setText(self.NOVALUE_LEN3);
      }
      // ... reference elevation
      if($.PA_sViewLabelBottom == null) {
        $.PA_sViewLabelBottom = Ui.loadResource(Rez.Strings.labelElevation);
      }
      self.oRezLabelBottom.setText($.PA_sViewLabelBottom);
      if($.PA_oSettings.fReferenceElevation != null) {
        self.oRezValueBottom.setText(self.stringElevation($.PA_oSettings.fReferenceElevation, false));
      }
      else {
        self.oRezValueBottom.setText(self.NOVALUE_LEN3);
      }
    }
    else if($.PA_iViewIndex == 3) {
      // ... density altitude
      if($.PA_sViewLabelTop == null) {
        $.PA_sViewLabelTop = Ui.loadResource(Rez.Strings.labelAltitudeDensity);
      }
      self.oRezLabelTop.setText($.PA_sViewLabelTop);
      if($.PA_oAltimeter.fAltitudeDensity != null) {
        self.oRezValueTop.setText(self.stringElevation($.PA_oAltimeter.fAltitudeDensity, false));
      }
      else {
        self.oRezValueTop.setText(self.NOVALUE_LEN3);
      }
      // ... temperature
      if($.PA_sViewLabelBottom == null) {
        $.PA_sViewLabelBottom = Ui.loadResource(Rez.Strings.labelTemperature);
      }
      self.oRezLabelBottom.setText($.PA_sViewLabelBottom);
      if($.PA_oAltimeter.fTemperatureISA != null and $.PA_oAltimeter.fTemperatureActual != null) {
        self.oRezValueBottom.setText(Lang.format("$1$ / ISA$2$", [self.stringTemperature($.PA_oAltimeter.fTemperatureActual, false), self.stringTemperature($.PA_oAltimeter.fTemperatureActual-$.PA_oAltimeter.fTemperatureISA, true)]));
      }
      else {
        self.oRezValueBottom.setText(self.NOVALUE_LEN3);
      }
    }
    else if($.PA_iViewIndex == 4) {
      // ... QFE (calibrated)
      if($.PA_sViewLabelTop == null) {
        $.PA_sViewLabelTop = Ui.loadResource(Rez.Strings.labelPressureQFE);
      }
      self.oRezLabelTop.setText($.PA_sViewLabelTop);
      if($.PA_oAltimeter.fQFE != null) {
        self.oRezValueTop.setText(self.stringPressure($.PA_oAltimeter.fQFE));
      }
      else {
        self.oRezValueTop.setText(self.NOVALUE_LEN3);
      }
      // ... temperature
      if($.PA_sViewLabelBottom == null) {
        $.PA_sViewLabelBottom = Ui.loadResource(Rez.Strings.labelPressureQFERaw);
      }
      self.oRezLabelBottom.setText($.PA_sViewLabelBottom);
      if($.PA_oAltimeter.fQFE_raw != null) {
        self.oRezValueBottom.setText(self.stringPressure($.PA_oAltimeter.fQFE_raw));
      }
      else {
        self.oRezValueBottom.setText(self.NOVALUE_LEN3);
      }
    }
  }

  function stringElevation(_fElevation, _bDelta) {
    var fValue = _fElevation * $.PA_oSettings.fUnitElevationCoefficient;
    var sValue = _bDelta ? fValue.format("%+.0f") : fValue.format("%.0f");
    return Lang.format("$1$ $2$", [sValue, $.PA_oSettings.sUnitElevation]);
  }

  function stringFlightLevel(_fElevation, _bAsFeet) {
    var fValue = _fElevation * 3.280839895f;
    if(_bAsFeet) {
      return Lang.format("$1$ ft", [fValue.format("%.0f")]);
    }
    else {
      var fValue2 = Math.round(fValue/500.0f)*5.0f;  // [FL]
      var sSign = "";
      if(fValue-100.0f*fValue2 > 100.0f) {
        sSign = "+";
      }
      if(fValue-100.0f*fValue2 < -100.0f) {
        sSign = "-";
      }
      return Lang.format("FL$1$$2$", [fValue2.format("%.0f"), sSign]);
    }
  }

  function stringPressure(_fPressure) {
    var fValue = _fPressure * $.PA_oSettings.fUnitPressureCoefficient;
    var sValue = fValue < 100.0f ? fValue.format("%.3f") : fValue.format("%.1f");
    return Lang.format("$1$ $2$", [sValue, $.PA_oSettings.sUnitPressure]);
  }

  function stringTemperature(_fTemperature, _bDelta) {
    var fValue = _fTemperature * $.PA_oSettings.fUnitTemperatureCoefficient;
    if(!_bDelta) {
      fValue += $.PA_oSettings.fUnitTemperatureOffset;
    }
    var sValue = _bDelta ? fValue.format("%+.1f") : fValue.format("%.1f");
    return Lang.format("$1$°$2$", [sValue, $.PA_oSettings.sUnitTemperature]);
  }

}

class PA_ViewDelegate extends Ui.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onMenu() {
    //Sys.println("DEBUG: PA_ViewDelegate.onMenu()");
    Ui.pushView(new MenuSettings(), new MenuSettingsDelegate(), Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onSelect() {
    //Sys.println("DEBUG: PA_ViewDelegate.onSelect()");
    $.PA_iViewIndex = ( $.PA_iViewIndex + 1 ) % 5;
    $.PA_sViewLabelTop = null;
    $.PA_sViewLabelBottom = null;
    Ui.requestUpdate();
    return true;
  }

}

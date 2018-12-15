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

using Toybox.Activity;
using Toybox.Application as App;
using Toybox.Sensor;
using Toybox.System as Sys;
using Toybox.Timer;

//
// GLOBALS
//

// Application settings
var PA_oSettings = null;

// Altimeter data
var PA_oAltimeter = null;

// Current view
var PA_oCurrentView = null;


//
// CLASS
//

class PA_App extends App.AppBase {

  //
  // VARIABLES
  //

  // UI update time
  private var oUpdateTimer;


  //
  // FUNCTIONS: App.AppBase (override/implement)
  //

  function initialize() {
    AppBase.initialize();

    // Application settings
    $.PA_oSettings = new PA_Settings();

    // Altimeter data
    $.PA_oAltimeter = new PA_Altimeter();

    // UI update time
    self.oUpdateTimer = null;
  }

  function onStart(state) {
    //Sys.println("DEBUG: PA_App.onStart()");

    // Enable sensor events
    Sensor.setEnabledSensors([Sensor.SENSOR_TEMPERATURE]);
    Sensor.enableSensorEvents(method(:onSensorEvent));

    // Start UI update timer (every multiple of 60 seconds)
    // NOTE: Sensor events will normally preempt this timer every second
    self.oUpdateTimer = new Timer.Timer();
    var iUpdateTimerDelay = (60-Sys.getClockTime().sec)%60;
    if(iUpdateTimerDelay > 0) {
      self.oUpdateTimer.start(method(:onUpdateTimer_init), 1000*iUpdateTimerDelay, false);
    }
    else {
      self.oUpdateTimer.start(method(:onUpdateTimer), 60000, true);
    }
  }

  function onStop(state) {
    //Sys.println("DEBUG: PA_App.onStop()");

    // Stop UI update timer
    if(self.oUpdateTimer != null) {
      self.oUpdateTimer.stop();
      self.oUpdateTimer = null;
    }

    // Disable sensor events
    Sensor.enableSensorEvents(null);
  }

  function getInitialView() {
    //Sys.println("DEBUG: PA_App.getInitialView()");

    return [new PA_View(), new PA_ViewDelegate()];
  }

  function onSettingsChanged() {
    //Sys.println("DEBUG: PA_App.onSettingsChanged()");
    self.updateApp();
  }


  //
  // FUNCTIONS: self
  //

  function updateApp() {
    //Sys.println("DEBUG: PA_App.updateApp()");

    // Load settings
    self.loadSettings();
    $.PA_oAltimeter.importSettings();

    // Update UI
    self.updateUi();
  }

  function loadSettings() {
    //Sys.println("DEBUG: PA_App.loadSettings()");

    // Load settings
    $.PA_oSettings.load();
  }

  function onSensorEvent(_oSensorInfo) {
    //Sys.println("DEBUG: PA_App.onSensorEvent());

    // Process sensor data
    // ... temperature
    if($.PA_oSettings.bReferenceTemperatureAuto) {
      if(_oSensorInfo has :temperature and _oSensorInfo.temperature != null) {
        $.PA_oAltimeter.setTemperatureActual(_oSensorInfo.temperature+273.15f);  // ... altimeter internals are °K
      }
    }
    else {
      $.PA_oAltimeter.setTemperatureActual(null);
    }
    // ... pressure
    var oActivityInfo = Activity.getActivityInfo();  // ... we need *raw ambient* pressure
    if(oActivityInfo has :ambientPressure and oActivityInfo.ambientPressure != null) {
      $.PA_oAltimeter.setQFE(oActivityInfo.ambientPressure);
    }

    // UI update
    self.updateUi();
  }

  function onUpdateTimer_init() {
    //Sys.println("DEBUG: PH_App.onUpdateTimer_init()");
    self.onUpdateTimer();
    self.oUpdateTimer = new Timer.Timer();
    self.oUpdateTimer.start(method(:onUpdateTimer), 60000, true);
  }

  function onUpdateTimer() {
    //Sys.println("DEBUG: PH_App.onUpdateTimer()");
    self.updateUi();
  }

  function updateUi() {
    //Sys.println("DEBUG: PA_App.updateUi()");

    // Update UI
    if($.PA_oCurrentView != null) {
      $.PA_oCurrentView.updateUi();
    }
  }

}

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

using Toybox.Lang;
using Toybox.Math;
using Toybox.System as Sys;

// REFERENCES:
//   https://store.icao.int/manual-on-automatic-meteorological-observing-systems-at-aerodromes-2011-doc-9837-english-printed.html ($$$)
//   https://www.wmo.int/pages/prog/www/IMOP/meetings/SI/ET-Stand-1/Doc-10_Pressure-red.pdf
//   https://en.wikipedia.org/wiki/Density_altitude#Calculation

//
// CLASS
//

class PA_Altimeter {

  //
  // CONSTANTS
  //

  // International Standard Atmosphere (ISA)
  public const ISA_PRESSURE_MSL = 101325.0f;  // [Pa] aka. QNE
  public const ISA_TEMPERATURE_MSL = 288.15f;  // [°K]
  public const ISA_TEMPERATURE_LRATE = -0.0065f;  // [°K/m]

  // International Civil Aviation Organization (OACI)
  public const ICAO_ALTITUDE_K1 = 44330.77f;
  public const ICAO_ALTITUDE_K2 = -11880.32f;
  public const ICAO_ALTITUDE_EXP = 0.190263f;
  public const ICAO_PRESSURE_EXP = 5.25588f;

  // Density Altitude
  public const DA_EXP = 0.234978f;


  //
  // VARIABLES
  //

  // Pressure
  public var fQFE;  // [Pa]
  public var fQFE_calibrated;  // [Pa]
  public var fQFE_raw;  // [Pa]
  public var fQNH;  // [Pa]

  // Altitude
  public var fAltitudeISA;  // [m]
  public var fAltitudeActual;  // [m]
  public var fAltitudeDensity;  // [m]

  // Temperature
  public var fTemperatureISA;  // [°K]
  public var fTemperatureActual;  // [°K]
  private var bTemperatureActualSet;

  // Filter (EMA)
  private var fEmaCoefficient_present;
  private var fEmaCoefficient_past;

  
  //
  // FUNCTIONS: self
  //

  function initialize() {
    self.reset();
  }

  function reset() {
    // Pressure
    self.fQFE = null;
    self.fQFE_calibrated = null;
    self.fQFE_raw = null;
    self.fQNH = self.ISA_PRESSURE_MSL;

    // Altitude
    self.fAltitudeISA = null;
    self.fAltitudeActual = null;
    self.fAltitudeDensity = null;

    // Temperature
    self.fTemperatureISA = null;
    self.fTemperatureActual = null;
    self.bTemperatureActualSet = false;

    // Filter (EMA)
    self.fEmaCoefficient_present = 1.0f;
    self.fEmaCoefficient_past = 0.0f;
  }

  function importSettings() {
    // QNH
    self.fQNH = $.PA_oSettings.fCalibrationQNH;
    
    // Time constant <-> Filter (EMA)
    if($.PA_oSettings.iGeneralTimeConstant) {
      self.fEmaCoefficient_past = Math.pow(Math.E, -1.0f/$.PA_oSettings.iGeneralTimeConstant);
    }
    else {
      self.fEmaCoefficient_past = 0.0f;
    }
    self.fEmaCoefficient_present = 1.0f - self.fEmaCoefficient_past;
    //Sys.println(Lang.format("DEBUG: EMA coefficient = $1$", [self.fEmaCoefficient_present]));
  }

  function setQFE(_fQFE) {  // [Pa]
    // Raw sensor value
    self.fQFE_raw = _fQFE;
    //Sys.println(Lang.format("DEBUG: QFE (raw) = $1$", [self.fQFE_raw]));

    // Calibrated value
    self.fQFE_calibrated = self.fQFE_raw * $.PA_oSettings.fCorrectionRelative + $.PA_oSettings.fCorrectionAbsolute;
    //Sys.println(Lang.format("DEBUG: QFE (calibrated) = $1$", [self.fQFE_calibrated]));

    // Final (EMA-filtered) value
    if(self.fQFE == null) {
      self.fQFE = self.fQFE_calibrated;
    }
    else {
      self.fQFE = self.fEmaCoefficient_present * self.fQFE_calibrated + self.fEmaCoefficient_past * self.fQFE;
    }
    //Sys.println(Lang.format("DEBUG: QFE (filtered) = $1$", [self.fQFE]));

    // Derive altitudes (ICAO formula)
    // ... ISA (QNH=QNE)
    self.fAltitudeISA = self.ICAO_ALTITUDE_K1 + self.ICAO_ALTITUDE_K2 * Math.pow(self.fQFE/100.0f, self.ICAO_ALTITUDE_EXP);
    //Sys.println(Lang.format("DEBUG: Altitude, ISA = $1$", [self.fAltitudeISA]));
    // ... actual
    self.fAltitudeActual = self.fAltitudeISA - (Math.pow(self.fQNH/self.ISA_PRESSURE_MSL, self.ICAO_ALTITUDE_EXP) - 1.0f)*self.ISA_TEMPERATURE_MSL/self.ISA_TEMPERATURE_LRATE;
    //Sys.println(Lang.format("DEBUG: Altitude, actual = $1$", [self.fAltitudeActual]));

    // Post-process
    self.postProcess();
  }

  function setQNH(_fQNH) {  // [Pa]
    // QNH
    self.fQNH = _fQNH;

    // ISA altitude (<-> QFE) available ?
    if(self.fAltitudeISA == null) {
      return;
    }

    // Derive altitude (ICAO formula)
    // ... actual
    self.fAltitudeActual = self.fAltitudeISA - (Math.pow(self.fQNH/self.ISA_PRESSURE_MSL, self.ICAO_ALTITUDE_EXP) - 1.0f)*self.ISA_TEMPERATURE_MSL/self.ISA_TEMPERATURE_LRATE;
    //Sys.println(Lang.format("DEBUG: Altitude, actual = $1$", [self.fAltitudeActual]));

    // Post-process
    self.postProcess();
  }

  function setAltitudeActual(_fAltitudeActual) {  // [m]
    // ISA altitude (<-> QFE) available ?
    if(self.fAltitudeISA == null) {
      return;
    }
    
    // Derive QNH (ICAO formula)
    self.fQNH = self.ISA_PRESSURE_MSL * Math.pow(1.0f + self.ISA_TEMPERATURE_LRATE*(self.fAltitudeISA-_fAltitudeActual)/self.ISA_TEMPERATURE_MSL, self.ICAO_PRESSURE_EXP);
    //Sys.println(Lang.format("DEBUG: QNH = $1$", [self.fQNH]));

    // Save altitude
    // ... actual
    self.fAltitudeActual = _fAltitudeActual;

    // Post-process
    self.postProcess();
  }

  function setTemperatureActual(_fTemperatureActual) {  // [°K]
    // Save temperature
    // ... actual
    if(_fTemperatureActual != null) {
      self.fTemperatureActual = _fTemperatureActual;
      self.bTemperatureActualSet = true;
    }
    else {
      self.bTemperatureActualSet = false;
    }

    // Post-process
    // NO! This only affects Density Altitude, which will be updated on setQFE()
  }

  function postProcess() {
    // Derive temperature
    // ... ISA
    self.fTemperatureISA = self.ISA_TEMPERATURE_MSL + self.ISA_TEMPERATURE_LRATE * self.fAltitudeActual;
    //Sys.println(Lang.format("DEBUG: Temperature, ISA = $1$", [self.fTemperatureISA]));
    // ... actual
    if(!self.bTemperatureActualSet) {
      self.fTemperatureActual = self.fTemperatureISA + $.PA_oSettings.fReferenceTemperatureISAOffset;
    }
    //Sys.println(Lang.format("DEBUG: Temperature, actual = $1$", [self.fTemperatureActual]));

    // Derive altitude
    // ... density
    self.fAltitudeDensity = self.ISA_TEMPERATURE_MSL/self.ISA_TEMPERATURE_LRATE * (Math.pow(self.fQFE*self.ISA_TEMPERATURE_MSL/self.ISA_PRESSURE_MSL/self.fTemperatureActual, self.DA_EXP) - 1.0f);
    //Sys.println(Lang.format("DEBUG: Altitude, density = $1$", [self.fAltitudeDensity]));
  }

}


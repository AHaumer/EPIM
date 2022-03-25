within EPIM.Examples;
model IMC_Vf
  "Test example: InductionMachineSquirrelCage fed by voltage/frequency inverter"
  extends Modelica.Icons.Example;
  constant Integer m=3 "Number of phases";
  parameter Modelica.Units.SI.Voltage VNominal=100 "Nominal RMS voltage per phase";
  parameter Modelica.Units.SI.Frequency fNominal=imc.imcData.fsNominal "Nominal frequency";
  parameter Modelica.Units.SI.Torque TLoad=161.4 "Nominal load torque";
  parameter Modelica.Units.SI.AngularVelocity wLoad(displayUnit="rev/min")=1440.45*2*Modelica.Constants.pi/60 "Nominal load speed";
  parameter Modelica.Units.SI.Inertia JLoad=imc.imcData.Jr "Load's moment of inertia";
  EPIM.Components.InductionMachineSquirrelCage imc(wM(fixed=true), deltaM(fixed=true))
    annotation (Placement(transformation(extent={{-20,-50},{0,-30}})));
  Modelica.Electrical.Machines.Sensors.CurrentQuasiRMSSensor currentQuasiRMSSensor
    annotation (Placement(transformation(extent={{-10,10},{10,-10}}, rotation=270,
        origin={-10,-10})));
  Modelica.Electrical.Polyphase.Sources.SignalVoltage signalVoltage(final m=m)
    annotation (Placement(transformation(
        origin={-10,40},
        extent={{10,10},{-10,-10}},
        rotation=270)));
  Modelica.Electrical.Polyphase.Basic.Star star(final m=m) annotation (
      Placement(transformation(extent={{10,-10},{-10,10}},
        rotation=90,
        origin={10,40})));
  Modelica.Electrical.Analog.Basic.Ground ground annotation (Placement(
        transformation(
        origin={10,10},
        extent={{-10,-10},{10,10}},
        rotation=0)));
  Modelica.Mechanics.Rotational.Components.Inertia loadInertia(J=JLoad)
    annotation (Placement(transformation(extent={{10,-50},{30,-30}})));
  Modelica.Mechanics.Rotational.Sources.QuadraticSpeedDependentTorque
    quadraticLoadTorque(
    w_nominal=wLoad,
    TorqueDirection=false,
    tau_nominal=-TLoad,
    useSupport=false) annotation (Placement(transformation(extent={{60,-50},
            {40,-30}})));
  Modelica.Electrical.Machines.Utilities.TerminalBox terminalBox(
      terminalConnection="D")
    annotation (Placement(transformation(extent={{-20,-34},{0,-14}})));
  EPIM.Components.VfController vfController(
    m=m,
    VNominal=VNominal,
    fNominal=fNominal,
    BasePhase=0)
    annotation (Placement(transformation(extent={{-50,30},{-30,50}})));
  Modelica.Blocks.Sources.Ramp ramp(
    height=fNominal,
    duration=1,
    offset=0,
    startTime=1)
    annotation (Placement(transformation(extent={{-80,30},{-60,50}})));
equation
  connect(star.pin_n, ground.p)
    annotation (Line(points={{10,30},{10,20}},   color={0,0,255}));
  connect(signalVoltage.plug_n, star.plug_p) annotation (Line(points={{-10,50},{-10,
          60},{10,60},{10,50}}, color={0,0,255}));
  connect(terminalBox.plug_sn, imc.plug_sn)
    annotation (Line(points={{-16,-30},{-16,-30}}, color={0,0,255}));
  connect(terminalBox.plug_sp, imc.plug_sp)
    annotation (Line(points={{-4,-30},{-4,-30}}, color={0,0,255}));
  connect(terminalBox.plugSupply, currentQuasiRMSSensor.plug_n)
    annotation (Line(
      points={{-10,-28},{-10,-20}},
      color={0,0,255}));
  connect(loadInertia.flange_b, quadraticLoadTorque.flange) annotation (
      Line(
      points={{30,-40},{40,-40}}));
  connect(imc.flange, loadInertia.flange_a)
    annotation (Line(points={{0,-40},{10,-40}}));
  connect(signalVoltage.plug_p, currentQuasiRMSSensor.plug_p)
    annotation (Line(points={{-10,30},{-10,-1.77636e-15}}, color={0,0,255}));
  connect(vfController.y, signalVoltage.v)
    annotation (Line(points={{-29,40},{-22,40}}, color={0,0,127}));
  connect(ramp.y, vfController.u)
    annotation (Line(points={{-59,40},{-52,40}}, color={0,0,127}));
  connect(vfController.deltaF, imc.deltaF)
    annotation (Line(points={{-40,29},{-40,-40},{-20,-40}}, color={0,0,127}));
  annotation (experiment(
      StopTime=100,
      Interval=0.001,
      Tolerance=1e-06,
      __Dymola_Algorithm="Dassl"), Documentation(
        info="<html>
<p>The induction machine with squirrel cage is supplied by a voltage/frequency-controller, commaned by a linear frequency ramp;
the machine starts from standstill, accelerating inertias against load torque quadratic dependent on speed, finally reaching nominal speed.</p>
<p>Default machine parameters are used.</p>
</html>"));
end IMC_Vf;

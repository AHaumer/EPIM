within EPIM.Examples;
model IMC_DOL "Test example: InductionMachineSquirrelCage direct-on-line"
  extends Modelica.Icons.Example;

  import SI=Modelica.SIunits;

  constant Integer m=3 "Number of phases";
  parameter SI.Voltage VNominal=100 "Nominal RMS voltage per phase";
  parameter SI.Time tStart1=0.1 "Start time";
  parameter SI.Frequency fNominal=50 "Nominal frequency";
  parameter SI.Torque TLoad=161.4 "Nominal load torque";
  parameter SI.AngularVelocity wLoad(displayUnit="rev/min")=1440.45*2*Modelica.Constants.pi/60 "Nominal load speed";
  parameter SI.Inertia JLoad=0.29 "Load's moment of inertia";

  Components.InductionMachineSquirrelCage aimc(
    imcData(
      Jr=aimcData.Jr,
      p=aimcData.p,
      fsNominal=aimcData.fsNominal,
      Rs=aimcData.Rs,
      TsRef=aimcData.TsRef,
      alpha20s(displayUnit="1/K") = aimcData.alpha20s,
      Lssigma=aimcData.Lssigma,
      Lm=aimcData.Lm,
      Lrsigma=aimcData.Lrsigma,
      Rr=aimcData.Rr,
      TrRef=aimcData.TrRef,
      alpha20r=aimcData.alpha20r),
      wM(fixed=true), deltaM(fixed=true))
    annotation (Placement(transformation(extent={{-20,-80},{0,-60}})));
  Modelica.Electrical.Machines.Sensors.CurrentQuasiRMSSensor currentQuasiRMSSensor
    annotation (Placement(transformation(extent={{-10,10},{10,-10}}, rotation=270,
        origin={-10,-30})));
  Modelica.Electrical.MultiPhase.Sources.SineVoltage sineVoltage(
    final m=m,
    V=fill(sqrt(2/3)*VNominal, m),
    freqHz=fill(fNominal, m))       annotation (Placement(transformation(
        origin={-10,30},
        extent={{10,10},{-10,-10}},
        rotation=270)));
  Modelica.Electrical.MultiPhase.Basic.Star star(final m=m) annotation (
      Placement(transformation(extent={{10,-10},{-10,10}},
        rotation=270,
        origin={-10,60})));
  Modelica.Electrical.Analog.Basic.Ground ground annotation (Placement(
        transformation(
        origin={-10,90},
        extent={{-10,10},{10,-10}},
        rotation=0)));
  Modelica.Mechanics.Rotational.Components.Inertia loadInertia(J=JLoad)
    annotation (Placement(transformation(extent={{10,-80},{30,-60}})));
  Modelica.Mechanics.Rotational.Sources.QuadraticSpeedDependentTorque
    quadraticLoadTorque(
    w_nominal=wLoad,
    TorqueDirection=false,
    tau_nominal=-TLoad,
    useSupport=false) annotation (Placement(transformation(extent={{60,-80},{40,-60}})));
  Modelica.Electrical.Machines.Utilities.TerminalBox terminalBox(
      terminalConnection="D")
    annotation (Placement(transformation(extent={{-20,-64},{0,-44}})));
  Modelica.Blocks.Sources.Constant fs(k=fNominal) annotation (Placement(transformation(extent={{-100,-80},{-80,-60}})));
  Modelica.Blocks.Continuous.Integrator theta_s(k=2*Modelica.Constants.pi)
    annotation (Placement(transformation(extent={{-70,-80},{-50,-60}})));
  Modelica.Electrical.MultiPhase.Ideal.IdealClosingSwitch switch(Ron={1e-5,1e-5,1e-5}, Goff={1e-5,1e-5,1e-5})
    annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=270,
        origin={-10,0})));
  Modelica.Blocks.Sources.BooleanStep booleanStep(startTime=tStart1, startValue=false)
                                                               annotation (Placement(transformation(extent={{-80,-10},{-60,10}})));
  Modelica.Blocks.Routing.BooleanReplicator booleanReplicator(nout=m)
    annotation (Placement(transformation(extent={{-46,-6},{-34,6}})));

  parameter Modelica.Electrical.Machines.Utilities.ParameterRecords.AIM_SquirrelCageData aimcData "Induction machine data"
    annotation (Placement(transformation(extent={{40,-40},{60,-20}})));
equation
  connect(star.pin_n, ground.p)
    annotation (Line(points={{-10,70},{-10,80}}, color={0,0,255}));
  connect(sineVoltage.plug_n, star.plug_p) annotation (Line(points={{-10,40},{-10,50}}, color={0,0,255}));
  connect(terminalBox.plug_sn, aimc.plug_sn) annotation (Line(
      points={{-16,-60},{-16,-60}},
      color={0,0,255}));
  connect(terminalBox.plug_sp, aimc.plug_sp) annotation (Line(
      points={{-4,-60},{-4,-60}},
      color={0,0,255}));
  connect(terminalBox.plugSupply, currentQuasiRMSSensor.plug_n)
    annotation (Line(
      points={{-10,-58},{-10,-49},{-10,-49},{-10,-40}},
      color={0,0,255}));
  connect(loadInertia.flange_b, quadraticLoadTorque.flange) annotation (
      Line(
      points={{30,-70},{40,-70}}));
  connect(aimc.flange, loadInertia.flange_a) annotation (Line(
      points={{0,-70},{10,-70}}));
  connect(fs.y, theta_s.u) annotation (Line(points={{-79,-70},{-72,-70}}, color={0,0,127}));
  connect(theta_s.y, aimc.deltaF) annotation (Line(points={{-49,-70},{-20,-70}}, color={0,0,127}));
  connect(sineVoltage.plug_p, switch.plug_p) annotation (Line(points={{-10,20},{-10,10}}, color={0,0,255}));
  connect(switch.plug_n, currentQuasiRMSSensor.plug_p)
    annotation (Line(points={{-10,-10},{-10,-15},{-10,-15},{-10,-20}}, color={0,0,255}));
  connect(booleanReplicator.y, switch.control)
    annotation (Line(points={{-33.4,0},{-27.7,0},{-27.7,2.10942e-15},{-22,2.10942e-15}}, color={255,0,255}));
  connect(booleanReplicator.u, booleanStep.y) annotation (Line(points={{-47.2,0},{-59,0}}, color={255,0,255}));
  annotation (experiment(
      StopTime=100,
      Interval=0.001,
      Tolerance=1e-06,
      __Dymola_Algorithm="Dassl"),                                      Documentation(
        info="<html>
<p>This is a copy from 
<a href=\"modelica://Modelica.Electrical.Machines.Examples.InductionMachines.IMC_DOL\">Electrical.Machines.Examples.InductionMachines.IMC_DOL</a>
using the local <a href=\"modelica://EPIM.Components.InductionMachineSquirrelCage\">InductionMachineSquirrelCage</a> model to demonstrate the difference in performance.</p>
<p>A script is provided to compare the reults of the MSL's and the EPIM machines. It runs both simulations and plots torque, speed and currents.</p>
<p>The main intention of the EPIM model is enlarge the possible stepsize used by the integration algorithm. This can be checked by simulating both models manually and checking the <code>Maximum integration stepsize</code> in the simulation log.</p>
</html>"),
    __Dymola_Commands(file="Resources/Scripts/compareToMSL.mos" "compareToMSL"));
end IMC_DOL;

within EPIM.Components;
model InductionMachineSquirrelCage
  "Induction machine model based on space phasor equations"
  extends Modelica.Electrical.Machines.Icons.Machine;
  import SI=Modelica.SIunits;
  import Modelica.Electrical.Machines.Thermal.convertResistance;
  import Modelica.Constants.pi;
  import Modelica.ComplexMath.j;
  import Modelica.ComplexMath.conj;
  import Modelica.ComplexMath.real;
  import Modelica.ComplexMath.imag;
  import Modelica.ComplexMath.'abs';
  import Modelica.ComplexMath.arg;
  import Modelica.ComplexMath.exp;
  import Modelica.ComplexMath.'sum';
  replaceable parameter ParameterRecords.ImcData imcData
    annotation (Placement(transformation(extent={{-10,60},{10,80}})));
  parameter SI.Temperature TsOperational=293.15
    "Operational temperature of stator resistance" annotation (Dialog(group="Operational temperatures"));
  parameter SI.Temperature TrOperational=293.15
    "Operational temperature of roator resistance" annotation (Dialog(group="Operational temperatures"));
  constant Integer m=3 "Number of phases";
  final parameter SI.Angle orientation[m]=imcData.orientation "Orientation of phases";
  final parameter Integer p=imcData.p "Number of pole pairs";
  final parameter SI.Inertia Jr=imcData.Jr "Rotor's moment of inertia";
  final parameter SI.Resistance Rs=convertResistance(imcData.Rs,imcData.TsRef,imcData.alpha20s,TsOperational)
    "Stator resistance per phase in warm condition";
  final parameter SI.Inductance Lssigma=imcData.Lssigma
    "Stator stray inductance per phase";
  final parameter SI.Inductance Lm=imcData.Lm
    "Stator main inductance per phase";
  final parameter SI.Inductance Lrsigma=imcData.Lrsigma
    "Rotor stray inductance per phase (equivalent to stator)";
  final parameter SI.Resistance Rr=convertResistance(imcData.Rr,imcData.TrRef,imcData.alpha20r,TrOperational)
    "Rotor resistance per phase (equivalent to stator) in warm condition";
  SI.Voltage vs[m] "Terminal voltages";
  SI.Current is[m] "Terminal currentss";
  SI.ComplexVoltage vs_S "Stator voltage space phasor in stator fixed frame";
  SI.ComplexCurrent is_S "Stator current space phasor in stator fixed frame";
  SI.ComplexVoltage vs_F "Stator voltage space phasor in choosen frame";
  SI.ComplexCurrent is_F "Stator current space phasor in choosen frame";
  SI.ComplexCurrent im_F "Magnetizing current space phasor in choosen frame";
  SI.ComplexCurrent ir_F "Rotor current space phasor in choosen frame";
  SI.ComplexMagneticFlux psis_F "Stator flux space phasor in choosen frame";
  SI.ComplexMagneticFlux psim_F "Main flux space phasor in choosen frame";
  SI.ComplexMagneticFlux psir_F "Rotor flux space phasor in choosen frame";
  SI.Torque tauM "Electrical torque";
  SI.Torque tauE "Mehcanical torque at flange";
  SI.AngularVelocity wM(start=0) "Mechanical angular velocity";
  SI.Angle deltaM(start=0) "Mechanical angle";
  SI.AngularVelocity wF "Angular velocity of choosen frame";
  Modelica.Mechanics.Rotational.Interfaces.Flange_a flange
    annotation (Placement(transformation(extent={{90,-10},{110,10}})));
  Modelica.Electrical.MultiPhase.Interfaces.PositivePlug plug_sp(m=m)
    annotation (Placement(transformation(extent={{50,90},{70,110}})));
  Modelica.Electrical.MultiPhase.Interfaces.NegativePlug plug_sn(m=m)
    annotation (Placement(transformation(extent={{-70,90},{-50,110}})));
  Modelica.Blocks.Interfaces.RealInput deltaF "Position of choosen frame"
    annotation (Placement(transformation(extent={{-120,-20},{-80,20}})));
equation
  //Terminal currents and voltages
  is = plug_sp.pin.i;
  is =-plug_sn.pin.i;
  vs = plug_sp.pin.v - plug_sn.pin.v;
  //Angle and angular velocity
  deltaM = flange.phi;
  wM=der(deltaM);
  wF=der(deltaF);
  //space phasor transformation
  vs_S = 2/m*'sum'({vs[k]*exp(j*orientation[k]) for k in 1:m});
  vs_F =vs_S*exp(-j*deltaF);
  //Flux linkages
  im_F = is_F +ir_F;
  psim_F = Lm*im_F;
  psis_F = Lssigma*is_F + psim_F;
  psir_F = Lrsigma*ir_F + psim_F;
  //2nd Kirchoff's law
  vs_F       =Rs*is_F + der(psis_F.re) + j*der(psis_F.im) + j*wF*psis_F;
  Complex(0) =Rr*ir_F + der(psir_F.re) + j*der(psir_F.im) + j*(wF - p*wM)*psir_F;
  //space phasor back transformation
  is_S =is_F*exp(j*deltaF);
  is = {real(is_S*exp(-j*orientation[k])) for k in 1:m};
  //Torque and equation of motion
  tauE = m/2*p*imag(is_F*conj(psim_F));
  tauM = flange.tau;
  Jr*der(wM)=tauE + tauM;
  annotation (defaultComponentName="imc",
  Documentation(info="<html>
<p>
This is a rather simple model of an induction machine based on space phasor equations to raise performance. 
</p>
<p>
Inductances and resistances are considered to be constant.
Other losses than Ohmic losses are neglected, temperatures are considered to be constant.
</p>
<p>
<ul>
<li>The phase voltages at the inputs are transformed to the space phasor in the stator fixed frame (Clarke).</li>
<li>This voltage space phasor is rotated to the choosen coordinate system (Park).</li>
<li>The main flux is calculated depending the actual magnetizing current space phasor.</li>
<li>The stator and rotor flux linkage is calculated.</li>
<li>Kirchhoff's second law is formulated for the stator and the rotor mesh.</li>
<li>The current space phasors of stator and rotor are a result of Kirchhoff's second law.</li>
<li>The current space phasor is rotated back to the stator fixed frame (inverse Park).</li>
<li>This space phasor is transformed back to phase currents (inverse Clarke) at the output.</li>
<li>Electrical torque is calculated.</li>
<li>Note: In this model, load torque is given as an input, and equation of motion is evaluated giving mechanical angular velocity at the output.</li>
</ul>
Note that the term Park is used for transformation from stator fixed frame to an arbitrary coordinate system (which could be the field-oriented frame). 
The angular velocity of the field fixed frame is hard to detect. Therefore, the rotor fixed frame with wk = p*wm is choosen, which eases numerical integration. 
</p>
<p>
Note that only one space phasor is used, representing the fundamental wave of the magnetic field. 
Bear in mind that the orientation of phases has to match between the machine model and your source.
</p>
<p>
Keep in mind that a Modelica tool solves the coupled non-linear differential and algebraic equations simultaneously. 
Implementing the same model in another simulation environment, you might have to consider iteration.
</p>
</html>"), Icon(graphics={Text(
          extent={{-100,100},{100,70}},
          lineColor={28,108,200})}));
end InductionMachineSquirrelCage;

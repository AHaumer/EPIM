within EPIM.UsersGuide;
class Concept "Description of concept"
  extends Modelica.Icons.Information;

  annotation (DocumentationClass=true, Documentation(info="<html>
<p>
Based on the knowledge that applying Clarke- and Park-transformation to the equations describing the behaviour of a rotatory field machine, 
we face the problem how to obtain the field position of an induction machine. 
For further simplification, the zero component is neglected, and the implementation is restricted to three phases.
</p>
<p>
In this experimental implementation the position of the stator voltage space phasor is used for the Park-transformation. 
To overcome the problem to determine the position of the stator voltage space phasor, 
a modified <a href=\"modelica://Modelica.Electrical.Machines.Utilities.VfController\">voltage/frequency controller </a> 
is used that calculates the phase angle and subsequently the three symmetrical phase voltages. 
The phase angle is fed as a signal to the machine model, and tehre it is used for the Part-transformation. 
This way in quasi-stationary point of operation teh space phasors consist of DC components which allow very performant action of the numerical integration algorithm.
</p>
</html>"));
end Concept;

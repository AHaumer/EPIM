within EPIM.ParameterRecords;
record ImcData
  import SI=Modelica.SIunits;
  extends
    Modelica.Electrical.Machines.Utilities.ParameterRecords.AIM_SquirrelCageData(
    final Js=Jr,
    final effectiveStatorTurns=1,
    final Lszero=Lssigma,
    final frictionParameters(
      final PRef=0,
      final wRef=2*pi*fsNominal/p,
      final power_w=2),
    final statorCoreParameters(
      final PRef=0,
      final VRef=100,
      final wRef=2*pi*fsNominal),
    final strayLoadParameters(
      final PRef=0,
      final IRef=100,
      final wRef=2*pi*fsNominal/p,
      final power_w=2));
  import Modelica.Constants.pi;
  parameter SI.Angle orientation[m]=
    {(k - 1)/m*2*pi for k in 1:m} "Orientation of phases";
  annotation(defaultComponentPrefixes="parameter", Icon(graphics={Text(
          extent={{-100,-10},{100,-30}},
          lineColor={28,108,200},
          textString="%Type")}));
end ImcData;

Class App.Installer
{
XData setup
{
<Manifest>
  <Default Name="SourceDir" Value="/home/irisowner/dev"/>
  <Default Name="Namespace" Value="REPORTS"/>
  <Default Name="app" Value="reports"/>

  <Namespace Name="${Namespace}" Code="REPORTSROUTINES" Data="REPORTSGLOBALS" Create="yes" Ensemble="1">

    <Configuration>
      <Database Name="REPORTSROUTINES" Dir="/usr/irissys/${app}/code" Create="yes" Resource="%DB_%DEFAULT" />
      <Database Name="REPORTSGLOBALS" Dir="/usr/irissys/${app}/glob" Create="yes" Resource="%DB_%DEFAULT" />
    </Configuration>
  </Namespace>
</Manifest>
}

ClassMethod setup(ByRef pVars, pLogLevel As %Integer = 3, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
  #; Let XGL document generate code for this method. 
  Quit ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "setup")
}

}

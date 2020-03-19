Class Demo.OperationalAnalytics.Table Extends %Persistent
{

Property RunTime As %TimeStamp;

Property Namespace As %String;

Property AvgTime As %Float;

Property AvgAckTime As %Float;

Property NumInbound As %Integer;

Property NumOutbound As %Integer;

Property MinTime As %Float;

Property MaxTime As %Float;

Storage Default
{
<Data name="TableDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>RunTime</Value>
</Value>
<Value name="3">
<Value>Namespace</Value>
</Value>
<Value name="4">
<Value>AvgTime</Value>
</Value>
<Value name="5">
<Value>AvgAckTime</Value>
</Value>
<Value name="6">
<Value>NumInbound</Value>
</Value>
<Value name="7">
<Value>NumOutbound</Value>
</Value>
<Value name="8">
<Value>MinTime</Value>
</Value>
<Value name="9">
<Value>MaxTime</Value>
</Value>
</Data>
<DataLocation>^Demo.OperationalAnal43E6.TableD</DataLocation>
<DefaultData>TableDefaultData</DefaultData>
<IdLocation>^Demo.OperationalAnal43E6.TableD</IdLocation>
<IndexLocation>^Demo.OperationalAnal43E6.TableI</IndexLocation>
<StreamLocation>^Demo.OperationalAnal43E6.TableS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

Class Demo.OperationalAnalytics.MetricsTable Extends %Persistent
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
<Data name="MetricsTableDefaultData">
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
<DataLocation>^Demo.Operatio43E6.MetricsTableD</DataLocation>
<DefaultData>MetricsTableDefaultData</DefaultData>
<IdLocation>^Demo.Operatio43E6.MetricsTableD</IdLocation>
<IndexLocation>^Demo.Operatio43E6.MetricsTableI</IndexLocation>
<StreamLocation>^Demo.Operatio43E6.MetricsTableS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

Class Demo.OperationalAnalytics.Compute Extends %SYS.Task.Definition
{

/*
*****************************************************
*                 ** N O T I C E **                 *
*               - TEST/DEMO SOFTWARE -              *
* This and related items are not supported by       *
* InterSystems as part of any released product.     *
* It is supplied by InterSystems as a demo/test     *
* tool for a specific product and version.          *
* The user or customer is fully responsible for     *
* the maintenance of this software after delivery,  *
* and InterSystems shall bear no responsibility nor *
* liabilities for errors or misuse of this item.    *
*                                                   *
*****************************************************
*
*
Code Description:
We will create an operational dashboard to illustrate key metrics for processing messages (i.e. average processing times, number of inbound/outbound messages) across all specified namespaces.
By extending %SYS.Task.Definition, we will be able to use the Task Manager to refresh the dashboard every hour with the latest messages from the preceding hour. 
The resulting table will be conveniently displayed as a dashboard in DeepSee.

The table definition will be created by Demo.OperationalAnalaytics.Table
*/
Method OnTask() As %Status
{
    // Specify the target namespace where the results should be displayed
	zn "REPORTS"
	
	// Set up the date/time to iterate through the preceding hour from current time
	// Makes a call to helper function PrevHour, defined below
	set tToday = $zdate($horolog,3) // store today's date in tToday
	set tPrevHour = ..PrevHour($zdatetime($h,3))

    set tPrevHour = 11
	
	set tBeginTime = tToday_" "_tPrevHour_":00:00.000"
	set tEndTime = tToday_" "_tPrevHour_":59:59.999"

    write "tBeginTime: "_tBeginTime

	// Specify all the namespaces to loop through in the ^ReportNamespaces index global
	set key = $Order(^ReportNamespaces(""))

	// Iterate through every namespace in ^ReportNamespaces global
	while key'="" {
		// switch to next namespace in list
		set tNamespace = $ZSTRIP(^ReportNamespaces(key),"*W")
		zn tNamespace
		
		// Separate tDateTime into separate date and time variables
		// The final time table will display the date/time when the refresh method was run
		set tDate = $piece(tBeginTime, " ", 1)
		set tTime = $extract($zdatetime($h,3),12,13)
		set tTime = tTime_":00:00.000"
		set tTime = tDate_" "_tTime
		
		// Dynamic SQL to fetch the messages from specified namespace in tNamespace
		// fn TIMESTAMPDIFF displays the difference of (TimeProcessed-TimeCreated) in milliseconds
        // Message statistics are stored in Ens.MessageHeader table that is SQL accessible
		set myquery = "SELECT avg({fn TIMESTAMPDIFF(SQL_TSI_FRAC_SECOND, (SELECT min(TimeCreated) FROM ens.messageheader WHERE SourceBusinessType=1 AND sessionId=MH.sessionId), TimeProcessed)}) as AvgTime, "_
							"avg({fn TIMESTAMPDIFF(SQL_TSI_FRAC_SECOND, TimeCreated, TimeProcessed)}) as AvgAckTime "_
							"FROM ens.messageheader MH "_
							"WHERE TargetBusinessType = 3 AND TimeCreated > '"_tBeginTime_"' AND TimeCreated < '"_tEndTime_"' "_
							"and not(targetconfigname='Ens.Alert') and (description is null) and (messagebodyid is not null)"

		
		set tStatement = ##class(%SQL.Statement).%New()
		set tStatement.%SelectMode = 1  // set the mode to ODBC
   		set qStatus = tStatement.%Prepare(myquery)
		if qStatus'=1 { write "%Prepare failed",$System.Status.DisplayError(qStatus) QUIT}
		set rset = tStatement.%Execute()

		// Iterate through the result set to find AVG_TIME and AVG_ACK_TIME
		while rset.%Next(){
			set tAvgTime = $FNUMBER(rset.AvgTime,"",0) // round and eliminate the decimal from milliseconds
			set tAvgAckTime = $FNUMBER(rset.AvgAckTime,"",0) // round and eliminate the decimal from milliseconds
		}
		
		// Determine the NumInbound (excluding null messages) and NumOutbound
		set myquery = "select distinct "_
							"(select count(*) from ens.messageheader where sourcebusinesstype=1 and not(targetconfigname='Ens.Alert') and (messagebodyid is not null) and (description is null) and TimeCreated > '"_tBeginTime_"' AND TimeCreated < '"_tEndTime_"') as NumInbound, "_
							"(select count(*) from ens.messageheader where targetbusinesstype=3 and not(targetconfigname='Ens.Alert') and (messagebodyid is not null) and (description is null) and TimeCreated > '"_tBeginTime_"' AND TimeCreated < '"_tEndTime_"') as NumOutbound "_
							"from ens.messageheader"

		set tStatement = ##class(%SQL.Statement).%New()
		set tStatement.%SelectMode = 1  // set the mode to ODBC
   		set qStatus = tStatement.%Prepare(myquery)
		if qStatus'=1 { write "%Prepare failed",$System.Status.DisplayError(qStatus) QUIT}
		set rset = tStatement.%Execute()
		
		// Iterate through the result set to find NumInbound and NumOutbound
		while rset.%Next(){		
			// Retrieve number of inbound and outbound messages
			set tNumInbound = rset.NumInbound
			set tNumOutbound = rset.NumOutbound
		}
		
		// If data did not exist for this namespace, skip onto the next namespace
		set myquery = "select max(AvgTimeDiff) as MaxAvgTime, min(AvgTimeDiff) as MinAvgTime "_
						"from (select avg({fn TIMESTAMPDIFF(SQL_TSI_FRAC_SECOND, (SELECT min(TimeCreated) FROM ens.messageheader WHERE SourceBusinessType=1 AND sessionId=MH.sessionId), TimeProcessed)}) as AvgTimeDiff "_
						"from ens.messageheader MH "_
						"where targetbusinesstype=3 and not(targetconfigname='Ens.Alert') and (description is null) and (messagebodyid is not null) and TimeCreated > '"_tBeginTime_"' AND TimeCreated < '"_tEndTime_"' "_
						"group by sessionid) "
						

		set tStatement = ##class(%SQL.Statement).%New()
		set tStatement.%SelectMode = 1  // set the mode to ODBC
   		set qStatus = tStatement.%Prepare(myquery)
		if qStatus'=1 { write "%Prepare failed",$System.Status.DisplayError(qStatus) QUIT}
		set rset = tStatement.%Execute()
		
		// Iterate through the result set to find MIN_TIME and MAX_TIME
		while rset.%Next(){
			// Retrieve Run_Time from the Query
			set tMinAvgTime = rset.MinAvgTime
			set tMaxAvgTime = rset.MaxAvgTime	 
		}
		
		// If no messages were run in the previous hour for the given namespace,
		// pad the data with "0"s and still list on the table
		if (tNumInbound=0 && tNumOutbound=0 && tAvgTime=0){
		 	set tMinAvgTime = 0
			set tMaxAvgTime = 0
		}
		
		// To format the time metrics to seconds from milliseconds, divide them by 1000
		set tAvgTime = tAvgTime / 1000
		set tAvgAckTime = tAvgAckTime / 1000
		set tMinAvgTime = tMinAvgTime / 1000
		set tMaxAvgTime = tMaxAvgTime / 1000
		
		// Insert the information from the current namespace into AvgProcTimeTable
		&SQL(INSERT INTO Demo_OperationalAnalytics.MetricsTable(RunTime,Namespace,AvgTime,AvgAckTime,NumInbound,NumOutbound,MinTime,MaxTime)
				VALUES (:tTime,:tNamespace,:tAvgTime,:tAvgAckTime,:tNumInbound,:tNumOutbound,:tMinAvgTime,:tMaxAvgTime))
		
		// iterate onto the next namespace listed in ^ReportNamespaces global, if exists
		zn "REPORTS" 
    	set key = $Order(^ReportNamespaces(key))
	}
	
	// Replace the cube name
	do ##class(Demo.OperationalAnalytics.MetricsTable).%BuildIndices()
	set tCubeRebuild = ##class(%DeepSee.Utils).%BuildCube("Operational Analytics")
	quit tCubeRebuild   // quit with a status of the cube build
}

ClassMethod PrevHour(pDateTime As %String) As %String
{
    /*
	Helper method to find the previous hour ONLY
	i.e. If current time is "2018-09-25 09:24:11",
			PrevHour will return "08"
	*/
  // Given pDateTime (ODBC), return the string of the previous hour, in ODBC format
	set tHorolog = $zdatetimeh(pDateTime,3)
	set tDate = $piece(tHorolog,",",1)
	set tTime = $piece(tHorolog,",",2)
	
	// Subtract 3600 from tTime to reduce time by ONE hour
	set tTime = tTime - 3600
	
	if tTime < 0 {
		// if tTime becomes a negative value, deduct ONE day from tDate component
		// and then add 3600*24 = 86400 to tTime
		set tDate = tDate - 1
		set tTime = tTime + 86400
	}
	
	set tOneHourBefore = tDate_","_tTime
	set tOneHourBefore = $zdatetime(tOneHourBefore,3)
	
	set tPrevHour = $piece(tOneHourBefore," ",2) // gets the time component of zDateTime
	set tPrevHour = $piece(tPrevHour,":",1) // gets the hour component from time

	return tPrevHour
}

}

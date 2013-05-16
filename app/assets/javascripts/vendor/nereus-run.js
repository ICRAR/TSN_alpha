var children = Array();

function run(userID)
	{
	if (children.length > 4)
		{
		alert("Warning: You have opened more than 4 clients. Please note that you will only receive credits at a rate of one client per core.");
		}
	if (userID == undefined)
		userID = -1;
	children[children.length] =window.open('http://'+location.hostname+':'+location.port+'/nereus/'+userID+'/run/', '', 'resizable=no,scrollbars=no,menubar=no,toolbar=no,location=no,width=400,height=400');
	children[children.length-1].moveTo((screen.width/2) - 200, (screen.height/2)-200);
	}

function javaCheck()
	{
	deployJava.setInstallerType('online');
	var versions = deployJava.getJREs();
	var retVal = true;

	if (!gotJava())
		{
		retVal = false;
		if (versions.length == 0)
			{
        		document.getElementById('contributionMessage').innerHTML = 'Java could not be detected.';
       			document.getElementById('contributionText').innerHTML = '<p>theSkyNet requires Java 1.6 Update 10 (or higher) to run.<br />Why not get it now?</p>';
			}
		 else
			{
        		document.getElementById('contributionMessage').innerHTML = 'Your version of java is out of date.';
			document.getElementById('contributionText').innerHTML = '<p>You currently have version ' + versions[0] + '.<br />theSkyNet requires Java 1.6 Update 10 (or higher) to run.</p>';
			}
		document.getElementById('javaMessage').innerHTML = '<a onclick="var javaWindow=window.opener.open(\'http://www.java.com\');javaWindow.focus();window.close()" class="button medium blue" style="text-align:center;cursor:pointer"><span>Install/Upgrade Java</span></a>';
		}
	//else document.getElementById('javaMessage').innerHTML = '(Detected java version: ' + versions + ')';
	
	return retVal;
	}
	
function gotJava()
{
   if (deployJava.versionCheck('1.6.0_10+'))
      return true;
   return false;
}

function showApplet()
{
    var app = document.getElementById("appletFrame");
    if (app == null)
        return;

    if (app.width == 0)
    {
	document.getElementById("appletButton").innerHTML = "Hide your client";	
       app.width = 430;
       app.height = 150;
	window.moveTo((screen.width/2) - 250, (screen.height/2)-275);
       window.resizeTo(500, 550);
    }
    else
    {
	document.getElementById("appletButton").innerHTML = "Show your client";
       app.width = app.height = 0;
	window.moveTo((screen.width/2) - 200, (screen.height/2)-200);
       window.resizeTo(400,400);
    }
}

function getQueryVariable(variable) {
  var query = window.location.search.substring(1);
  var vars = query.split("&");
  for (var i=0;i<vars.length;i++) {
    var pair = vars[i].split("=");
    if (pair[0] == variable) {
      return pair[1];
    }
}}

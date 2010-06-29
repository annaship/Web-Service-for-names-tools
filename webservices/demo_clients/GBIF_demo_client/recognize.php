<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
 <head>
     <title>ECAT Development Site</title>
     <link rel="stylesheet" type="text/css" href="http://ecat-dev.gbif.org/media/main.css" />
     <script type="text/javascript" src="http://ecat-dev.gbif.org/js/jquery-1.4.min.js"></script>
     <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
 </head>
<body>
<div id="wrapper">
<div id="header">
	<p>
		<a href="http://ecat-dev.gbif.org"><img src="http://ecat-dev.gbif.org/media/logo.jpg"></a>
	</p>
		<div id="menu">
			<ul>
				<li><a href="http://ecat-dev.gbif.org/browser.php">Browser</a></li>
				<li><a href="http://ecat-dev.gbif.org/api/index.php">Webservices</a></li>
				<li><a href="http://ecat-dev.gbif.org/parser.php">Name Parser</a></li>
				<li><a href="http://ecat-dev.gbif.org/ubio/recognize.php">Name Finding</a></li>
				<li><a href="http://ecat-dev.gbif.org/taxontagger/index.html">Taxon Tagger</a></li>
			</ul>
		</div>
</div>
<div id="content">
  <br>
  <div align='center'>
    <?php
//this should be in a config file in a production implementation of this reference client
/////////////////////////////////////////////////////////
$taxon_finder_web_service_url = "http://localhost:4567"; 
/////////////////////////////////////////////////////////


//sort out what type of content the user has submitted

//user specified URL
if ($_POST["url"]) {
  $content = "url";
  $url = $_POST["url"];
}

//example URL
if (($_POST["url2"]) && ($_POST["url2"] != "none")) {
  $content = "url";
  $url = $_POST["url2"];
}

//user specified freetext
if ($_POST["freetext"]) {
  $content = "text";
  $freetext = $_POST["freetext"];
}


//deal with the uploaded file ** make sure the tmp directory has the correct permissions for this script to write to **
$upload = @$_FILES["upload"];

if($upload['name']) {
  $upload_file = true;
  echo "<p align='center'><b>Reading ".$upload['name']."</b></p>";
  flush();
  $copylocation = "tmp/".$upload['name'].'.txt';
  if(file_exists($copylocation)) {
    unlink($copylocation);
    }
  copy ($upload['tmp_name'], $copylocation);


// build the url to pass to the url function of the taxonfinder webservice
  $current_dir = preg_replace('/\?.*$/', '', $_SERVER['REQUEST_URI']);
  $current_dir = 'http://'.$_SERVER['HTTP_HOST'].'/'.ltrim(dirname($current_dir), '/').'/';
  $url = $current_dir."/tmp/".$upload['name'];
  unset($upload);
  $content = "url";
}


//If the user hasn't requested any content to be run against taxonfinder yet, we present the input form    
    if (!$content)
    {
      ?>
        <table width="272" border="0" cellspacing="2" cellpadding="">
                <form action='recognize.php' METHOD='POST' ENCTYPE='multipart/form-data'>
                <tr>
                        <td>
                                        <table width="468" height='350' border="0" cellspacing="2" cellpadding="0">
                                <tr>
                                    <td width=120>Upload File:</td>
                                    <td><INPUT TYPE=file NAME=upload SIZE=50 ACCEPT=text></td></tr>
                                <tr>
                                    <td>Enter URL:</td>
                                    <td><input type=text size=80 name=url></td></tr>
                                <tr>
                                    <td>Example URLs:</td>
                                    <td>
                                        <select name=url2 size='1'>";
                        <?php           
                                                $file = file("../test-data/testpages.txt");
                                                $num = count($file);
                                                echo "<option value='none'>- - Choose an example URL - -</option>\n";
                                                for($i=0 ; $i<$num ; $i++)
                                                {
                                                    $example=trim($file[$i]);
                                                    if (strlen($example)>4){
                                                    $option = explode("\t", $example, 2);
                                                    if (count($option)>1){
                                                                echo "<option value='".trim($option[0])."'>".substr($option[1],0,88)."</option>\n";
                                                    }else{
                                                                echo "<option value='".trim($option[0])."'>".substr($option[0],0,88)."</option>\n";
                                                    }
                                                    }
                                                }
                        ?>              
                                </select>
                                </td></tr>
                                <tr>
                                    <td>Enter Free Text:</td>
                                    <td><textarea rows='3' cols='78' name='freetext'></textarea></td>
                                </tr>
                                <tr><td></td>
                                    <td><input type=submit value='Submit'></td>
                                </tr>
                        </table>
                        </td>
                        <td>
                        <input type=hidden name=func value=submit>
                        </form>
                        </td>
                </tr>
        </table><?php
        
    }
    ?>
    <p>
<?php
if ($content)
{
// Once the user has specied content, we query the taxonfinder webservice with the content


$time_start = microtime(true);

 if ($content == "url") {
   $xml = simplexml_load_file("$taxon_finder_web_service_url/find?url=$url");
   if ($upload_file)
   {
     //dump the uploaded file now that we've used it.
     unlink($copylocation);
   }
   else
   {
   echo "<p><b>Reading <a href=$url target='new'>$url</a></b> </p>";
   }
  }
 elseif ($content == "text") 
 {
   $xml = simplexml_load_file("http://$taxon_finder_web_service_url/find?text=$freetext");
 }
 
//parse the xml response and move it to an array
  $possible_names = array();
  foreach ($xml->names->name as $name) 
  {
    $namespaces = $name->getNameSpaces(true);
    $dwc = $name->children($namespaces['dwc']);
    $verbatim = (string )$name->verbatim;
    $scientific = (string )$dwc->scientificName;
    $possible_names[$verbatim] = $scientific;
  }

    $time_end = microtime(true);
//tell the client how long the process took and how many names were found

    $time = $time_end - $time_start;
    echo "<b>Strings: ".count(@$possible_names)."</b><br />
          <b>Time:&nbsp;".round($time,2)." sec</b><br /><br /><br />";

?>
      <table class='nice' width=900>
        <tr>
          <th>Name String (as appears in text)</th>
          <th>Verbatim String</th>
        </tr>   
<?php       
//print each verbatim name and scientific name string in the table
      foreach( $possible_names as $vern_name => $sci_name){
      	echo "<tr><td>$vern_name</td><td>$sci_name</td></tr>";
      }       
      
    }
?>
      </table>
    </div>
  <br/>
  <br/>
</div>
			<div id="footer">
                    <ul class="sepmenu">
                      <li><a href="http://code.google.com/p/gbif-ecat/">ECAT @ GoogleCode</a></li>
                      <li>&copy; 2009 <a href="http://www.gbif.org">GBIF</a></li>
                      <li>AppRoot: http://ecat-dev.gbif.org</li>
                    </ul>        
			</div>
		</div>
	</body>
</html>

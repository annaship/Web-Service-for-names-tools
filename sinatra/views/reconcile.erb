<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
 <head>
     <title>BoA Names Services Development Site</title>
     <link rel="stylesheet" type="text/css" href="stylesheets/main.css" />
     <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
 </head>
<body>
<div id="wrapper">
<div id="header">
	<!-- <p>
		<a href="http://ecat-dev.gbif.org"><img src="http://ecat-dev.gbif.org/media/logo.jpg"></a>
	</p> -->
		<!-- <div id="menu">
			<ul>
				<li><a href="http://ecat-dev.gbif.org/browser.php">Browser</a></li>
				<li><a href="http://ecat-dev.gbif.org/api/index.php">Webservices</a></li>
				<li><a href="http://ecat-dev.gbif.org/parser.php">Name Parser</a></li>
				<li><a href="http://ecat-dev.gbif.org/ubio/recognize.php">Name Finding</a></li>
				<li><a href="http://ecat-dev.gbif.org/taxontagger/index.html">Taxon Tagger</a></li>
			</ul>
		</div> -->
		<h2>Scientific Names Reconciliation Tool</h2>                                                                     
		<div align='left'>
			<form action="<?= $_SERVER['PHP_SELF'] ?>" method="post">
			<input type="submit" name="submit" value="Refresh This Page" />
			</form>
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

if ($_POST["url1"] && $_POST["url2"])

{
  $content = "url";
  $url1 = $_POST["url1"];
  $url2 = $_POST["url2"];
}

//user specified freetext
if ($_POST["freetext1"] && $_POST["freetext2"]) {
  $content = "text";
  $freetext1 = urlencode($_POST["freetext1"]);
  $freetext2 = urlencode($_POST["freetext2"]);
	// echo "</b><br /><p />4 = ".$content;
	// echo "</b><br /><p />freetext1 = ".$freetext1;
	// echo "</b><br /><p />freetext2 = ".$freetext2;
}


//deal with the uploaded file ** make sure the tmp directory has the correct permissions for this script to write to **
// print_r(@$_FILES["upload2"]);
$upload1 = @$_FILES["upload1"];
$upload2 = @$_FILES["upload2"];

// echo "5 = HERE";

if($upload1['name'] && $upload2['name']) {
  $upload_file = true;
  echo "<p align='center'><b>Reading ".$upload1['name']."</b></p>";
  echo "<p align='center'><b>Reading ".$upload2['name']."</b></p>";
  flush();
  $copylocation1 = "tmp/".$upload1['name'];
  $copylocation2 = "tmp/".$upload2['name'];
  if(file_exists($copylocation1) && file_exists($copylocation2)) {
    unlink($copylocation1);
    unlink($copylocation2);
    }
  copy ($upload1['tmp_name'], $copylocation1);
  copy ($upload2['tmp_name'], $copylocation2);


// build the url to pass to the url function of the taxonfinder webservice
  $current_dir = preg_replace('/\?.*$/', '', $_SERVER['REQUEST_URI']);
  $current_dir = 'http://'.$_SERVER['HTTP_HOST'].'/'.ltrim(dirname($current_dir), '/').'/';
  $url1 = $current_dir."tmp/".$upload1['name'];
  unset($upload1);
  $url2 = $current_dir."tmp/".$upload2['name'];
  unset($upload2);
  $content = "url";
}

//example URL
if ($_POST["url1"] && ($_POST["url_e"]) && ($_POST["url_e"] != "none")) {
  $content = "url";
  $url1 = $_POST["url1"];
  $url2 = $_POST["url_e"];
}
if ($_POST["freetext1"] && ($_POST["url_e"]) && ($_POST["url_e"] != "none")) {
  $content 	 = "text_url";
  $freetext1 = urlencode($_POST["freetext1"]);
  $url2 		 = $_POST["url_e"];
}
if($upload1['name'] && ($_POST["url_e"]) && ($_POST["url_e"] != "none")) {
  $upload_file = true;
  echo "<p align='center'><b>Reading ".$upload1['name']."</b></p>";
  flush();
  $copylocation1 = "tmp/".$upload1['name'];
  if(file_exists($copylocation1)) {
    unlink($copylocation1);
    }
  copy ($upload1['tmp_name'], $copylocation1);

// build the url to pass to the url function of the taxonfinder webservice
  $current_dir = preg_replace('/\?.*$/', '', $_SERVER['REQUEST_URI']);
  $current_dir = 'http://'.$_SERVER['HTTP_HOST'].'/'.ltrim(dirname($current_dir), '/').'/';
  $url1 = $current_dir."tmp/".$upload1['name'];
  $url2 = $_POST["url_e"];
  unset($upload1);
  $content = "url";
}


//If the user hasn't requested any content to be run against taxonfinder yet, we present the input form    
    if (!$content)
    {
      ?>
        <!-- <table width="272" border="0" cellspacing="2" cellpadding=""> -->
          <form action='reconcile.php' METHOD='POST' ENCTYPE='multipart/form-data'>
          <!-- <tr> -->
           <!-- <td> -->
					<table width=70% hight=50% border="0" cellspacing="2" cellpadding="0">
						<tr>
						<th></th><th>List to compare</th><th></th><th>Master list</th>
						</tr>
						<tr>
						<td></td><td></td>
						<td>Master list URLs:</td>
						<td>
						<select name=url_e size='1'>";
						<?php           
						        $file = file("../webservices/texts/master_lists.txt");
						        $num = count($file);
						        echo "<option value='none'>- - Choose an Master list URL - -</option>\n";
						        for($i=0 ; $i<$num ; $i++)
						        {
						            $example = trim($file[$i]);
												$name_to_show = basename($example);
						            if (strlen($example)>4){
						            $option = explode("\t", $example, 2);
						            // if (count($option)>1){
						                        echo " <option class='pretty' value='".trim($option[0])."'> ".substr($name_to_show, 0, 88)." </option>\n";
						            // }else{
						                        // echo "<option value='".trim($option[0])."'> ".substr($name_to_show, 0, 88)." </option>\n";
						            // }
						            }
						        }
						?>              
	          </select>
	          </td></tr>
            <tr>
                <td width=120>Upload File 1:</td>
                <td><INPUT TYPE=file NAME=upload1 SIZE=48 ACCEPT=text></td>
                <td width=120>Upload File 2:</td>
                <td><INPUT TYPE=file NAME=upload2 SIZE=48 ACCEPT=text></td></tr>
            <tr>
                <td>Enter URL 1:</td>
                <td><input type=text size=58 name=url1></td>
                <td>Enter URL 2:</td>
                <td><input type=text size=58 name=url2></td></tr>
            <tr>
                <td>Enter Free Text:</td>
                <td><textarea rows='3' cols='51' name='freetext1'></textarea></td>
                <td>Enter Free Text:</td>
                <td><textarea rows='3' cols='51' name='freetext2'></textarea></td>
            </tr>
            <tr>
								<td></td><td></td>
                <td><input type=submit value='Submit'></td>
            </tr>
    </table>
    <!-- </td>
    <td> -->
    <input type=hidden name=func value=submit>
    </form>
    <!-- </td>
                </tr> -->
        <!-- </table> -->
<?php
        
    }
    ?>
    <p>
<?php
if ($content)
{
// Once the user has specied content, we query the taxonfinder webservice with the content


$time_start = microtime(true);

 if ($content == "url") {
   $result = file_get_contents("$taxon_finder_web_service_url/match?url1=$url1&url2=$url2");
   // echo "URA, $content == \"url\" </b><br /><p />".$result;
   if ($upload_file)
   {
     //dump the uploaded file now that we've used it.
     unlink($copylocation1);
		 if ($copylocation2)
     {unlink($copylocation2);}
   }
   else
   {
	   echo "<p><b>Reading <a href=$url1 target='new'>$url1</a></b> </p>";
	   echo "<p><b>Reading <a href=$url2 target='new'>$url2</a></b> </p>";
   }
  }
 elseif ($content == "text") 
 {
   $result = file_get_contents("$taxon_finder_web_service_url/match?text1=$freetext1&text2=$freetext2");
   // echo "URA, $content == \"text\" </b><br /><p />".$result;
 }
 elseif ($content == "text_url") 
 {
   $result = file_get_contents("$taxon_finder_web_service_url/match?text1=$freetext1&url2=$url2");
   // echo "URA, $content == \"text\" </b><br /><p />".$result;
 }

 
//parse the xml response and move it to an array
  $possible_names = array();
	$possible_names = explode("\n", $result);

    $time_end = microtime(true);
//tell the client how long the process took and how many names were found

    $time = $time_end - $time_start;
    echo "<b>Time:&nbsp;".round($time, 2)." sec</b><br /><br /><br />";

?>
		<table class='nice'>
  <!-- <table class='nice' width=30% border = 0> -->
        <tr>
          <th>Name to compare</th><th></th>
          <th>Matched name</th>
        </tr>   
<?php       
	
//print each verbatim name and scientific name string in the table
    //   foreach($possible_names as $vern_name => $sci_name){
			foreach($possible_names as $names){
				list($bad_name, $good_name) = explode(" ---> ", $names); 
				if ($bad_name && $good_name)
				{
	      	echo "<tr><td>$bad_name</td><td>---></td><td>$good_name</td></tr>";			
				}
      	// echo "<tr><td colspan = 3, align = left>$name</td></tr>";
      }       
    }
?>
      </table>
    </div>
  <br/>
  <br/>
</div>
			<div id="footer">
                    <!-- <ul class="sepmenu">
                      <li><a href="http://code.google.com/p/gbif-ecat/">ECAT @ GoogleCode</a></li>
                      <li>&copy; 2009 <a href="http://www.gbif.org">GBIF</a></li>
                      <li>AppRoot: http://ecat-dev.gbif.org</li>
                    </ul>         -->
			</div>
		</div>
	</body>
</html>

<!-- $chars = str_split( $freetext1, 1 );
foreach ( $chars as $char )
{
	$num = ord($char);
  echo "{$num}<br />\n";
} -->

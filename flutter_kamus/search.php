<?php 
  $db = "udacoding";
  $host = "localhost";
  $db_user = 'root';
  $db_password = '';
  //MySql server and database info
  
  $link = mysqli_connect($host, $db_user, $db_password, $db);
  //connecting to database

  function matchper($s1, $s2){ 
        similar_text(strtolower($s1), strtolower($s2), $per);
        return $per; //fungsi matchingin kata
  }

  if(isset($_REQUEST["query"])){
      $query = strtolower($_REQUEST["query"]);
  }else{
      $query = "";
  } //request mengandung post dan get


  $json["error"] = false;
  $json["errmsg"] = "";
  $json["data"] = array();


  $busing=$_REQUEST['query'];
  $sql = "SELECT * FROM kamus where busing like '%".$busing."%'";
  $res = mysqli_query($link, $sql);
  $numrows = mysqli_num_rows($res);
  if($numrows > 0){
     //check if there is any data
     $katalist= array();

      while($obj = mysqli_fetch_object($res)){
           $matching = matchper($query, $obj->bind);
           
           $katalist[$matching][$obj->id] = $obj->bind;
           
      }

      krsort($katalist); 
      //sorting array

      foreach($katalist as $innerarray){
         foreach($innerarray as $id => $busing){
            $subdata = array(); //buat array
            $subdata["id"] = "$id"; //return as string
            $subdata["bahasausing"] =  $busing; 
           

            array_push($json["data"], $subdata); //push sub array into $json array
            
         }
      }
  }else{
      $json["error"] = true;
      $json["errmsg"] = "No any data to show.";
  }

  mysqli_close($link);
  
  header('Content-Type: application/json');
  
  // tell browser that its a json data
  echo json_encode($json);

?>
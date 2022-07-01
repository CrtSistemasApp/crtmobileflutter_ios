<?php 

$host= $_GET['host'];
$dbname=$_GET['bdname'];
$dns = "mysql:localhost=$host;dbname=$dbname";
$user = $_GET['usuario'];
$pass = $_GET['senha'];
$query = $_GET['query'];


date_default_timezone_set('America/Sao_Paulo');


try {
    $pdo = new PDO($dns, $user, $pass);

    $dados = array();

$query = $pdo->query("$query;");
$res = $query->fetchAll(PDO::FETCH_ASSOC);


for ($i=0; $i < count($res); $i++) { 
      foreach ($res[$i] as $key => $value) {}

      	$dados = $res;


}

echo ($res) ?
json_encode(array("code" => 1, "result"=>$dados)) : 
json_encode(array("code" => 0, "message"=>"Dados incorretos!")); 


} catch (Exception $e) {

    echo "Erro ao conectar com o banco de dados! " . $e;
}

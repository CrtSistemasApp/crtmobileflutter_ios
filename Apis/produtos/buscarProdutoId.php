<?php 

$host= $_POST['host'];
$dbname=$_POST['bdname'];
$user = $_POST['usuario'];
$pass = $_POST['senha'];
$dns = "mysql:localhost=$host;dbname=$dbname";
$proid = $_GET['proid'];
$empid = $_GET['empid'];

date_default_timezone_set('America/Sao_Paulo');


try {
    $pdo = new PDO($dns, $user, $pass);

    $dados = array();

$query = $pdo->query("SELECT DISTINCT P.*, SUM(CASE WHEN LOPQTD > '0.000' THEN LOPQTD ELSE 0 END) AS LOPQTD FROM PRODUTOS P JOIN LOCAISESTOQUEPRODUTO L ON (P.PROID = L.PROID) WHERE P.PRODESATIVADO != '1' AND P.PROREFERENCIA = '$proid' AND L.EMPID = '$empid';");
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
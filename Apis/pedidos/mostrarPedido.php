<?php 

$host= $_POST['host'];
$dbname=$_POST['bdname'];
$user = $_POST['usuario'];
$pass = $_POST['senha'];
$dns = "mysql:localhost=$host;dbname=$dbname";
$ORCID = $_GET['ORCID'];
$dados = array();

date_default_timezone_set('America/Sao_Paulo');


try {
    $pdo = new PDO($dns, $user, $pass);

$query = $pdo->query("SELECT CLIENTES.CLINOMERAZAO, ORCAMENTOS.ORCID, ORCAMENTOS.VENID, ORCAMENTOS.CLIID,
ORCAMENTOITENS.PROID 
FROM CLIENTES, ORCAMENTOS, ORCAMENTOITENS
WHERE ORCAMENTOS.ORCID = ORCAMENTOITENS.ORCID AND ORCAMENTOS.ORCID = $ORCID AND CLIENTES.CLIID = ORCAMENTOS.CLIID;");
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
?>
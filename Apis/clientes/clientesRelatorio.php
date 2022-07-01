<?php


$host= $_POST['host'];
$dbname=$_POST['bdname'];
$user = $_POST['usuario'];
$pass = $_POST['senha'];
$dns = "mysql:localhost=$host;dbname=$dbname";
$empid = $_GET['empid'];
$venid = $_GET['venid'];
$datainicial =  $_GET['datainicial'];
$datafinal =  $_GET['datafinal'];

date_default_timezone_set('America/Sao_Paulo');


try {
    $pdo = new PDO($dns, $user, $pass);


    $dados = array();

    $query = $pdo->query("SELECT DISTINCT O.CLIID, C.CLINOMERAZAO FROM ORCAMENTOS O JOIN CLIENTES C ON(O.CLIID = C.CLIID) WHERE O.EMPID = '$empid' AND O.VENID='$venid' AND (O.ORCDATA BETWEEN '$datainicial' AND '$datafinal')  ORDER BY O.CLIID;");
    $res = $query->fetchAll(PDO::FETCH_ASSOC);


    for ($i = 0; $i < count($res); $i++) {
        foreach ($res[$i] as $key => $value) {
        }

        $dados = $res;
    }

    echo ($res) ?
        json_encode(array("code" => 1, "result" => $dados)) :
        json_encode(array("code" => 0, "message" => "Dados incorretos!"));
} catch (Exception $e) {

    echo "Erro ao conectar com o banco de dados! " . $e;
}

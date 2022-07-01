<?php


$host= $_POST['host'];
$dbname=$_POST['bdname'];
$user = $_POST['usuario'];
$pass = $_POST['senha'];
$dns = "mysql:localhost=$host;dbname=$dbname";
$cnpj = $_GET['cnpj'];
$usuid = $_GET['usuid'];


date_default_timezone_set('America/Sao_Paulo');


try {
    $pdo = new PDO($dns, $user, $pass);


    $dados = array();

    $query = $pdo->query("SELECT E.* FROM EMPRESAUSUARIOS EU INNER JOIN EMPRESAS E ON (EU.EMPID = E.EMPID) WHERE USUID='$usuid' ORDER BY E.EMPID");
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
?>
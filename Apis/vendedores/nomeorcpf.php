<?php

$host= $_POST['host'];
$dbname=$_POST['bdname'];
$user = $_POST['usuario'];
$pass = $_POST['senha'];
$dns = "mysql:localhost=$host;dbname=$dbname";
$idCli = $_GET['idCliente'];
$busca = $_GET['busca'];


date_default_timezone_set('America/Sao_Paulo');



try {
    $pdo = new PDO($dns, $user, $pass);

    $dados = array();


    $query = $pdo->query("SELECT * FROM VENDEDORES V INNER JOIN EMPRESAUSUARIOS E ON(V.USUID = E.USUID) WHERE UPPER(VENNOME) LIKE UPPER('%$busca%') AND VENSTATUS='A';");


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

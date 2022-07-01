<?php

$host= $_POST['host'];
$dbname=$_POST['bdname'];
$user = $_POST['usuario'];
$pass = $_POST['senha'];
$dns = "mysql:localhost=$host;dbname=$dbname";
$idCli = $_GET['idCliente'];
$busca = $_GET['busca'];
$cnpj = $_GET['cnpj'];

date_default_timezone_set('America/Sao_Paulo');

if ($cnpj != null) {
    $busca = 'NULL';
}


try {
    $pdo = new PDO($dns, $user, $pass);

    $dados = array();

    if ($cnpj != null) {
        $query = $pdo->query("SELECT DISTINCT * FROM CLIENTES WHERE CLICODIGO = '$cnpj' OR UPPER(CLINOMERAZAO) LIKE UPPER('%$busca%')  OR UPPER(CLICPF) LIKE UPPER('%$cnpj%')  OR UPPER(CLIFONE01) LIKE UPPER('%$cnpj%') AND EMPID=$idCli;");
    } else {
        $query = $pdo->query("SELECT DISTINCT * FROM CLIENTES WHERE UPPER(CLINOMERAZAO) LIKE UPPER('%$busca%') OR UPPER(CLINOME) LIKE UPPER('%$busca%')  AND EMPID=$idCli;");
    }

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

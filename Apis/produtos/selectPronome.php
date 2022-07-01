<?php

$host= $_POST['host'];
$dbname=$_POST['bdname'];
$user = $_POST['usuario'];
$pass = $_POST['senha'];
$dns = "mysql:localhost=$host;dbname=$dbname";
$idCli = $_GET['idCliente'];
$busca = $_GET['busca'];
$preco = $_GET['preco'];

date_default_timezone_set('America/Sao_Paulo');

if ($preco != null) {
    $busca = 'NULL';
}


try {
    $pdo = new PDO($dns, $user, $pass);

    $dados = array();

    if ($preco != null) {
        $query = $pdo->query("SELECT DISTINCT P.*, L.LOPQTD FROM PRODUTOS P JOIN LOCAISESTOQUEPRODUTO L ON (P.PROID = L.PROID) WHERE UPPER(PRONOME) LIKE UPPER('%$busca%') OR UPPER(PROVALORVENDA1) LIKE UPPER('%$preco%') AND P.EMPID=$idCli AND P.PRODESATIVADO != '1' GROUP BY P.PROID;");
    } else {
        $query = $pdo->query("SELECT DISTINCT SUM(CASE WHEN LOPQTD > '0.000' THEN LOPQTD ELSE 0 END) AS LOPQTD, P.* FROM PRODUTOS P INNER JOIN LOCAISESTOQUEPRODUTO L  WHERE (UPPER(PRONOME) LIKE UPPER('%$busca%')) AND (L.PROID = P.PROID) AND L.EMPID='$idCli' AND P.PRODESATIVADO != '1' GROUP BY L.PROID;");
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

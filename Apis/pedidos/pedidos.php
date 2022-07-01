<?php

$host= $_POST['host'];
$dbname=$_POST['bdname'];
$user = $_POST['usuario'];
$pass = $_POST['senha'];
$dns = "mysql:localhost=$host;dbname=$dbname";
$orcid = $_GET['orcid'];
$busca = $_GET['busca'];

date_default_timezone_set('America/Sao_Paulo');


try {
    $pdo = new PDO($dns, $user, $pass);

    $dados = array();

    $VENDID = $_GET['vendid'];


    if ($orcid != null) {

        $query = $pdo->query("SELECT O.ORCID, V.VENNOME,
    C.CLINOMERAZAO,  C.CLINOME, O.ORCVALORTOTAL,
    O.ORCOBS, O.ORCFORMAPAGAMENTOTXT, 
    O.ORCDATA, 
    O.ORCHORA, 
    O.ORCSTATUS
    FROM ORCAMENTOS O
    JOIN CLIENTES C
    ON (O.CLIID = C.CLIID)
    JOIN VENDEDORES V
    ON (V.VENID = O.VENID)
    WHERE  UPPER(O.ORCID) LIKE UPPER('%$orcid%') AND V.VENID = $VENDID;");
    } else {
        $query = $pdo->query("SELECT O.ORCID, V.VENNOME,
        C.CLINOMERAZAO, O.ORCVALORTOTAL, 
        C.CLINOME,
        O.ORCOBS, O.ORCFORMAPAGAMENTOTXT, 
        O.ORCDATA, 
        O.ORCHORA,
        O.ORCSTATUS
        FROM ORCAMENTOS O
        JOIN CLIENTES C
        ON (O.CLIID = C.CLIID)
        JOIN VENDEDORES V
        ON (V.VENID = O.VENID)
        WHERE  UPPER(C.CLINOMERAZAO) LIKE UPPER('%$busca%') AND V.VENID = $VENDID");
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

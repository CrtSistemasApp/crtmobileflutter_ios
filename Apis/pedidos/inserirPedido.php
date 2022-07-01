<?php
header('Content-Type: application/json');
$host = $_GET['host'];
$dbname = $_GET['bdname'];
$dns = "mysql:localhost=$host;dbname=$dbname";
$user = $_GET['usuario'];
$pass = $_GET['senha'];


date_default_timezone_set('America/Sao_Paulo');


try {
    $pdo = new PDO($dns, $user, $pass);


    $VENID = $_POST['VENID'];
    $CLIID = $_POST['CLIID'];
    $ORCOBS = $_POST['ORCOBS'];
    $ORCOBS2 = $_POST['ORCOBS2'];
    $ORCDATA = $_POST['ORCDATA'];
    $ORCHORA = $_POST['ORCHORA'];
    $ORCVALORTOTAL = $_POST['ORCVALORTOTAL'];
    $EMPID = $_POST['EMPID'];
    $ORCFORMAPAGAMENTOTXT = $_POST['ORCFORMAPAGAMENTOTXT'];
    $last_id = '';

    $res = $pdo->prepare("INSERT into ORCAMENTOS (CLIID, ORCDATA, ORCVALORTOTAL, ORCHORA, EMPID, VENID, ORCOBS2, ORCOBS, ORCFORMAPAGAMENTOTXT) VALUES (?,?,?,?,?,?,?,?,?)");


    $result = $res->execute([$CLIID, $ORCDATA, $ORCVALORTOTAL, $ORCHORA, $EMPID, $VENID, $ORCOBS, $ORCOBS2, $ORCFORMAPAGAMENTOTXT]);

    if ($result === TRUE) {


        $last_id = $pdo->lastInsertId();
    }

    echo json_encode([
        'success' => $result,
        'ORCID' => $last_id
    ]);
} catch (Exception $e) {

    echo "Erro ao conectar com o banco de dados! " . $e;
}

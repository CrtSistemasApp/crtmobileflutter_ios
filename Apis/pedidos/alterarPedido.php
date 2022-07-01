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
    $ORCID = $_POST['ORCID'];
    $ORCSTATUS = 'A';
    $List = $_POST['LIST'];

    $res = $pdo->prepare("UPDATE ORCAMENTOS SET ORCID=?, CLIID=?, ORCDATA=?, ORCVALORTOTAL=?, ORCHORA=?, EMPID=?, VENID=?, ORCOBS2=?, ORCOBS=?, ORCFORMAPAGAMENTOTXT=?, ORCSTATUS=? WHERE ORCID=?");
    $result = $res->execute([$ORCID, $CLIID, $ORCDATA, $ORCVALORTOTAL, $ORCHORA, $EMPID, $VENID, $ORCOBS, $ORCOBS2, $ORCFORMAPAGAMENTOTXT, $ORCSTATUS, $ORCID]);



    echo json_encode([
        'success' => $result
        
    ]);
} catch (Exception $e) {

    echo "Erro ao conectar com o banco de dados! " . $e;
}

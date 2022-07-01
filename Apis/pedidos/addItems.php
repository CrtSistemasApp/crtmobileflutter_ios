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
    $ORCID = $_POST['ORCID'];
    $PROID = $_POST['PROID'];
    $ORIVALOR  = $_POST['ORIVALOR'];
    $ORIQTD = $_POST['ORIQTD'];
    $ORIDESCONTO = $_POST['ORIDESCONTO'];
    $LOCID = $_POST['LOCID'];
    $ORIOBS = $_POST['ORIOBS'];
    $CORID = $_POST['CORID'];
    $TAMID = $_POST['TAMID'];

    $res = $pdo->prepare("INSERT into ORCAMENTOITENS (ORCID, PROID, ORIVALOR, ORIDESCONTO, ORIQTD, LOCID, ORIOBS, CORID, TAMID) VALUES (?,?,?,?,?,?,?,?,?)");


    $result = $res->execute([$ORCID, $PROID, $ORIVALOR, $ORIDESCONTO, $ORIQTD, $LOCID, $ORIOBS, $CORID, $TAMID]);


    echo json_encode([
        'success' => $result,
        'ORCID' => $ORCID,
        'PROID' => $PROID,
        'ORIVALOR' => $ORIVALOR,
        'ORIQTD' => $ORIQTD,
        'LOCID' => $LOCID,
        'ORIOBS' => $ORIOBS,
        'CORID' => $CORID,
        'TAMID' => $TAMID

    ]);
} catch (Exception $e) {

    echo "Erro ao conectar com o banco de dados! " . $e;
}

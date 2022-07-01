<?php
header('Content-Type: application/json');
$host= $_POST['host'];
$dbname=$_POST['bdname'];
$user = $_POST['usuario'];
$pass = $_POST['senha'];
$dns = "mysql:localhost=$host;dbname=$dbname";
$empid = $_GET['empid'];
$corid = $_GET['corid'];
$tamid = $_GET['tamid'];
$proid = $_GET['proid'];
$qtd = $_GET['qtd'];


date_default_timezone_set('America/Sao_Paulo');


try {
    $pdo = new PDO($dns, $user, $pass);


    $res = $pdo->prepare("UPDATE LOCAISESTOQUEPRODUTO SET LOPQTD = LOPQTD+? WHERE CORID =? AND TAMID =? AND PROID=? AND EMPID=?; ");
    $result = $res->execute([$qtd, $corid, $tamid, $proid, $empid]);


    echo json_encode([
        'success' => $result

    ]);
} catch (Exception $e) {

    echo "Erro ao conectar com o banco de dados! " . $e;
}
<?php 
header('Content-Type: application/json');

$host= $_GET['host'];
$dbname=$_GET['bdname'];
$dns = "mysql:localhost=$host;dbname=$dbname";
$user = $_GET['usuario'];
$pass = $_GET['senha'];
$proref = $_POST['proref'];
$proimg = $_POST['url'];

date_default_timezone_set('America/Sao_Paulo');


try {
    $pdo = new PDO($dns, $user, $pass);



$res = $pdo->prepare("UPDATE PRODUTOS SET PROIMAGEM=?  WHERE PROREFERENCIA=?");


$result = $res->execute([$proimg, $proref]);


echo json_encode([
    'success' => $result,
    'url' => $proimg
]);

} catch (Exception $e) {

    echo "Erro ao conectar com o banco de dados! " . $e;
}
?>
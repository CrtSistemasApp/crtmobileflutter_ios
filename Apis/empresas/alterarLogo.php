<?php 
header('Content-Type: application/json');

$host= $_GET['host'];
$dbname=$_GET['bdname'];
$dns = "mysql:localhost=$host;dbname=$dbname";
$user = $_GET['usuario'];
$pass = $_GET['senha'];
$cnpj = $_POST['cnpj'];
$url = $_POST['url'];

date_default_timezone_set('America/Sao_Paulo');


try {
    $pdo = new PDO($dns, $user, $pass);



$res = $pdo->prepare("UPDATE EMPRESAS SET LOGOMARCA=?  WHERE EMPCNPJ=?");


$result = $res->execute([$url, $cnpj]);


echo json_encode([
    'success' => $result,
    'url' => $url
]);

} catch (Exception $e) {

    echo "Erro ao conectar com o banco de dados! " . $e;
}

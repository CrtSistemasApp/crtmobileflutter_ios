<?php

$host = $_POST['host'];
$dbname = $_POST['bdname'];
$user = $_POST['usuario'];
$pass = $_POST['senha'];
$dns = "mysql:localhost=$host;dbname=$dbname";


date_default_timezone_set('America/Sao_Paulo');


try {
    $pdo = new PDO($dns, $user, $pass);

    echo (json_encode(array("message" => 'Conectado ao banco')));
} catch (Exception $e) {

    echo (json_encode(array("message" => 'Erro ao conectar com o banco de dados! ' . $e)));
}

<?php

$host = $_GET['host'];
$dbname = $_GET['bdname'];
$dns = "mysql:localhost=$host;dbname=$dbname";
$user = $_GET['usuario'];
$pass = $_GET['senha'];
$cliente =  $_GET['cliente'];


date_default_timezone_set('America/Sao_Paulo');


try {
    $pdo = new PDO($dns, $user, $pass);



    $query = $pdo->query("ALTER TABLE CLIENTES AUTO_INCREMENT = $cliente;");

    
} catch (Exception $e) {

    echo "Erro ao conectar com o banco de dados! " . $e;
}

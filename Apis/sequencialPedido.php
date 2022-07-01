<?php

$host = $_GET['host'];
$dbname = $_GET['bdname'];
$dns = "mysql:localhost=$host;dbname=$dbname";
$user = $_GET['usuario'];
$pass = $_GET['senha'];
$pedido =  $_GET['orcamento'];


date_default_timezone_set('America/Sao_Paulo');


try {
    $pdo = new PDO($dns, $user, $pass);



    $query = $pdo->query("ALTER TABLE ORCAMENTOS AUTO_INCREMENT = $pedido;");

    
} catch (Exception $e) {

    echo "Erro ao conectar com o banco de dados! " . $e;
}
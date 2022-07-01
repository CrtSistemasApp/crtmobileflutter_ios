<?php

//Função para Criptografar os Dados no Banco
function Criptografar($Dados)
{
    $Valor = '';
    for ($i = 0; $i < strlen(utf8_decode($Dados)); $i++) {
        $Valor = $Valor . Chr(ord($Dados[$i]) + 34);
    }
    return utf8_encode($Valor);
}



$host = $_POST['host'];
$dbname = $_POST['bdname'];
$dns = "mysql:localhost=$host;dbname=$dbname";
$user = $_POST['usuario'];
$pass = $_POST['senha'];


date_default_timezone_set('America/Sao_Paulo');


try {
    $pdo = new PDO($dns, $user, $pass);

    $usuario = $_GET['user'];
    $senha = $_GET['pass'];

    $senha = Criptografar($senha);

    $dados = array();

    $query = $pdo->query("SELECT * 
FROM VENDEDORES V
JOIN ACSUSUARIOS AC
ON (V.USUID = AC.USUID)
WHERE VENNOME = '$usuario' AND AC.USUSENHA = '$senha';");
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

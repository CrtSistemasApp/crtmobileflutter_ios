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


    $nomeFantasia = $_POST['nomeFantasia'];
    $razaosocial = $_POST['razaosocial'];
    $cpf_cnpj = $_POST['cpf_cnpj'];
    $rg_ie = $_POST['rg_ie'];
    $tel1 = $_POST['tel1'];
    $tel2 = $_POST['tel2'];
    $tipoPessoa = $_POST['tipoPessoa'];
    $email = $_POST['email'];
    $site = $_POST['site'];
    $obs = $_POST['obs'];
    $logradouro = $_POST['logradouro'];
    $cidade = $_POST['cidade'];
    $bairro = $_POST['bairro'];
    $cep = $_POST['cep'];
    $uf = $_POST['uf'];
    $idCliente = $_GET['idCliente'];
    $munid = $_POST['munid'];
    $clistatus = "N";


    //CONSULTA PARA TRAZER O CPF E EMAIL CASO JÁ EXISTA NO BANCO
    $res = $pdo->query("SELECT * from CLIENTES where CLICPF = '$cpf_cnpj' AND EMPID='$idCliente'");
    $dados = $res->fetchAll(PDO::FETCH_ASSOC);
    $linhas = count($dados);
    if ($linhas > 0) {

        $cpf_recup = $dados[0]['CLICPF'];
        $empid = $dados[0]['EMPID'];
    }


    if ($cpf_cnpj != @$cpf_recup && $idCliente != @$empid) {

        $res = $pdo->prepare("INSERT into CLIENTES (CLINOME, CLINOMERAZAO, CLICPF, CLIRG, CLIFONE01, CLIFONE02, CLITIPOCLIENTE, CLIEMAIL, CLICONTATO, CLICOMENTARIO, CLIENDERECO, CLICIDADE, CLICEP, CLIBAIRRO, CLIUF, EMPID, MUNID, CLISTATUS) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");


        $result = $res->execute([$nomeFantasia, $razaosocial, $cpf_cnpj, $rg_ie, $tel1, $tel2, $tipoPessoa, $email, $site, $obs, $logradouro, $cidade, $cep,  $bairro, $uf, $idCliente, $munid, $clistatus]);


        echo (json_encode(array("message" => 'Cliente cadastrado com sucesso')));
    } else if ($cpf_cnpj == @$cpf_recup && $idCliente != @$empid) {

        $res = $pdo->prepare("INSERT into CLIENTES (CLINOME, CLINOMERAZAO, CLICPF, CLIRG, CLIFONE01, CLIFONE02, CLITIPOCLIENTE, CLIEMAIL, CLICONTATO, CLICOMENTARIO, CLIENDERECO, CLICIDADE, CLICEP, CLIBAIRRO, CLIUF, EMPID, MUNID, CLISTATUS) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");


        $result = $res->execute([$nomeFantasia, $razaosocial, $cpf_cnpj, $rg_ie, $tel1, $tel2, $tipoPessoa, $email, $site, $obs, $logradouro, $cidade, $cep,  $bairro, $uf, $idCliente, $munid, $clistatus]);


        echo (json_encode(array("message" => 'Cliente cadastrado com sucesso')));
    } else {

        echo (json_encode(array("message" => 'CPF já Cadastrado ou Cliente cadastrado na Empresa')));
    }
} catch (Exception $e) {

    echo "Erro ao conectar com o banco de dados! " . $e;
}
